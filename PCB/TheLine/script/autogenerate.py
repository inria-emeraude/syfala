import argparse
import re
import uuid

import pcbnew


SPEAKER_REF_RE = re.compile(r"LS(\d+)$")
FIXED_STRIP_JUMPER_RE = re.compile(r"JP([1-9]|1[0-9]|2[0-9]|3[0-2])$")

CONNECTOR_REFS = {"J1", "J2", "J3", "J4"}
FIXED_LEFT_AUX_REFS = ("R9", "D1")
U8_LOCAL_JUMPERS = ("JP100", "JP101", "JP102")
EXCLUDED_FP_PREFIXES = ("Connector_", "Jumper:")

FIXED_BUS_VIA_Y_MAX_MM = 90.0
LEFT_FANOUT_X_MAX_MM = 80.0
LEFT_LOCAL_FANOUT_X_MAX_MM = 78.5
RIGHT_FANOUT_X_MIN_MM = 230.5
RIGHT_FANOUT_SIGNAL_Y_MAX_MM = 123.5
RIGHT_CONNECTOR_CLUSTER_X_MIN_MM = 235.0
BUS_TRACK_MIN_LENGTH_MM = 20.0
LOCAL_HORIZONTAL_EXTENSION_MIN_MM = 0.0
PLANE_MARGIN_MM = 0.25
BOTTOM_SILK_LOGO_MIN_SIZE_MM = 10.0

def mm(value):
    return pcbnew.FromMM(value)


def to_mm(value):
    return pcbnew.ToMM(value)


def vector_mm(x_mm, y_mm):
    return pcbnew.VECTOR2I(mm(x_mm), mm(y_mm))


def iter_footprints(board):
    return list(board.GetFootprints())


def iter_tracks(board):
    return list(board.GetTracks())


def iter_zones(board):
    return list(board.Zones())


def iter_drawings(board):
    return list(board.GetDrawings())


def get_pos_mm(item):
    pos = item.GetPosition()
    return to_mm(pos.x), to_mm(pos.y)


def get_bbox_center_mm(item):
    bbox = item.GetBoundingBox()
    cx = bbox.GetX() + bbox.GetWidth() / 2
    cy = bbox.GetY() + bbox.GetHeight() / 2
    return to_mm(cx), to_mm(cy)


def get_track_endpoints_mm(track):
    start = track.GetStart()
    end = track.GetEnd()
    return to_mm(start.x), to_mm(start.y), to_mm(end.x), to_mm(end.y)


def move_item_mm(item, dx_mm, dy_mm):
    if abs(dx_mm) < 1e-9 and abs(dy_mm) < 1e-9:
        return
    item.Move(vector_mm(dx_mm, dy_mm))


def shift_track_rigid(track, dx_mm, dy_mm=0.0):
    sx_mm, sy_mm, ex_mm, ey_mm = get_track_endpoints_mm(track)
    track.SetStart(vector_mm(sx_mm + dx_mm, sy_mm + dy_mm))
    track.SetEnd(vector_mm(ex_mm + dx_mm, ey_mm + dy_mm))


def load_board(path):
    return pcbnew.LoadBoard(path)


def find_footprint_or_die(board, reference):
    footprint = board.FindFootprintByReference(reference)
    if footprint is None:
        raise RuntimeError(f"Footprint not found: {reference}")
    return footprint


def find_speakers(board):
    speakers = []
    for footprint in iter_footprints(board):
        match = SPEAKER_REF_RE.fullmatch(footprint.GetReference())
        if not match:
            continue
        speakers.append((int(match.group(1)), footprint))

    speakers.sort(key=lambda item: item[0])
    if not speakers:
        raise RuntimeError("No LS1..LSn speaker footprints were found in the PCB.")
    return speakers


def load_custom_speaker_template(path):
    custom_board = load_board(path)
    if custom_board is None:
        raise RuntimeError(f"Could not load custom footprint board: {path}")
    footprints = list(custom_board.GetFootprints())
    if not footprints:
        raise RuntimeError(f"No footprint found in custom footprint board: {path}")
    return footprints[0]


def replace_speaker_footprints(board, template_footprint):
    speakers = find_speakers(board)
    for _, old_footprint in speakers:
        reference = old_footprint.GetReference()
        position = old_footprint.GetPosition()
        orientation = old_footprint.GetOrientation()
        layer = old_footprint.GetLayer()
        old_footprint.CopyFrom(template_footprint)
        old_footprint.SetReference(reference)
        old_footprint.SetPosition(position)
        old_footprint.SetOrientation(orientation)
        old_footprint.SetLayer(layer)


def make_block_reference(target_ref, original_ref, index):
    if original_ref.startswith("LS"):
        return target_ref
    if original_ref:
        return f"{original_ref}_{target_ref}"
    return f"BLK{index}_{target_ref}"


def get_pad_net_map(footprint):
    return {
        pad.GetNumber(): pad.GetNetname()
        for pad in footprint.Pads()
        if pad.GetNumber()
    }


def apply_pad_net_map(board, footprint, pad_net_map):
    for pad in footprint.Pads():
        pad_number = pad.GetNumber()
        if not pad_number:
            continue
        net_name = pad_net_map.get(pad_number)
        if net_name:
            pad.SetNet(board.FindNet(net_name))
        else:
            pad.SetNetCode(0)


def build_custom_net_map(custom_anchor, target_pad_net_map):
    net_map = {}
    for pad in custom_anchor.Pads():
        pad_number = pad.GetNumber()
        if not pad_number:
            continue
        custom_net_name = pad.GetNetname()
        target_net_name = target_pad_net_map.get(pad_number)
        if custom_net_name and target_net_name:
            net_map[custom_net_name] = target_net_name
    return net_map


def apply_net_map_to_footprint(board, footprint, net_map):
    for pad in footprint.Pads():
        custom_net_name = pad.GetNetname()
        target_net_name = net_map.get(custom_net_name)
        if target_net_name:
            pad.SetNet(board.FindNet(target_net_name))
        elif custom_net_name:
            existing_net = board.FindNet(custom_net_name)
            if existing_net is not None:
                pad.SetNet(existing_net)
            else:
                pad.SetNetCode(0)
        else:
            pad.SetNetCode(0)


def import_custom_block(board, custom_pcb_path):
    custom_board = load_board(custom_pcb_path)
    if custom_board is None:
        raise RuntimeError(f"Could not load custom block board: {custom_pcb_path}")

    custom_speakers = find_speakers(custom_board)
    custom_anchor = custom_speakers[0][1]
    anchor_pos = custom_anchor.GetPosition()

    target_speakers = find_speakers(board)
    target_positions = [
        (
            footprint.GetReference(),
            footprint.GetPosition(),
            footprint.GetOrientation(),
            footprint.GetLayer(),
            get_pad_net_map(footprint),
        )
        for _, footprint in target_speakers
    ]

    for _, footprint in target_speakers:
        board.Remove(footprint)

    for target_ref, target_pos, target_orientation, target_layer, target_pad_net_map in target_positions:
        dx = target_pos.x - anchor_pos.x
        dy = target_pos.y - anchor_pos.y
        custom_net_map = build_custom_net_map(custom_anchor, target_pad_net_map)

        for index, custom_fp in enumerate(custom_board.GetFootprints()):
            clone = custom_fp.Duplicate().Cast()
            clone.Move(pcbnew.VECTOR2I(dx, dy))
            clone.SetReference(make_block_reference(target_ref, custom_fp.GetReference(), index))
            if custom_fp.GetReference().startswith("LS"):
                clone.SetOrientation(target_orientation)
                clone.SetLayer(target_layer)
            board.Add(clone)
            if custom_fp.GetReference().startswith("LS"):
                apply_pad_net_map(board, clone, target_pad_net_map)
            else:
                apply_net_map_to_footprint(board, clone, custom_net_map)

        for track in custom_board.GetTracks():
            clone = track.Duplicate().Cast()
            clone.Move(pcbnew.VECTOR2I(dx, dy))
            net_name = track.GetNetname()
            mapped_net_name = custom_net_map.get(net_name, net_name)
            if mapped_net_name:
                clone.SetNet(board.FindNet(mapped_net_name))
            else:
                clone.SetNetCode(0)
            board.Add(clone)

        for drawing in custom_board.GetDrawings():
            if drawing.GetLayerName() in {"Edge.Cuts", "User.Drawings"}:
                continue
            clone = drawing.Duplicate().Cast()
            clone.Move(pcbnew.VECTOR2I(dx, dy))
            board.Add(clone)


def find_sexpr_block(text, start_index):
    depth = 0
    for index in range(start_index, len(text)):
        char = text[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return text[start_index : index + 1], index + 1
    raise RuntimeError("Unterminated footprint block in KiCad PCB file.")


def extract_first_footprint_block(pcb_path):
    with open(pcb_path, "r", encoding="utf-8") as handle:
        text = handle.read()

    search_index = 0
    first_block = None
    while True:
        start_index = text.find("(footprint ", search_index)
        if start_index < 0:
            break
        block, end_index = find_sexpr_block(text, start_index)
        if first_block is None:
            first_block = block
        if re.search(r'\(property "Reference" "LS\d+"', block):
            return block
        search_index = end_index

    if first_block is not None:
        return first_block
    raise RuntimeError(f"No footprint found in custom footprint board: {pcb_path}")


def replace_footprint_uuids(block):
    return re.sub(r'\(uuid "[^"]+"\)', lambda _: f'(uuid "{uuid.uuid4()}")', block)


def replace_speaker_footprints_in_output(output_path, custom_pcb_path):
    template_block = extract_first_footprint_block(custom_pcb_path)

    with open(output_path, "r", encoding="utf-8") as handle:
        board_text = handle.read()

    result_parts = []
    cursor = 0
    while True:
        start_index = board_text.find("(footprint ", cursor)
        if start_index < 0:
            result_parts.append(board_text[cursor:])
            break

        block, end_index = find_sexpr_block(board_text, start_index)
        match = re.search(r'\(property "Reference" "(LS\d+)"', block)
        if match is None:
            result_parts.append(board_text[cursor:end_index])
            cursor = end_index
            continue

        reference = match.group(1)
        at_match = re.search(r'\(at ([^ )]+) ([^ )]+)(?: ([^ )]+))?\)', block)
        if at_match is None:
            raise RuntimeError(f"Could not find placement for speaker footprint {reference}.")
        original_at = at_match.group(0)

        new_block = template_block
        new_block = re.sub(r'\(property "Reference" "[^"]+"', f'(property "Reference" "{reference}"', new_block, count=1)
        new_block = re.sub(r'\(at [^ )]+ [^ )]+(?: [^ )]+)?\)', original_at, new_block, count=1)
        new_block = replace_footprint_uuids(new_block)

        result_parts.append(board_text[cursor:start_index])
        result_parts.append(new_block)
        cursor = end_index

    with open(output_path, "w", encoding="utf-8") as handle:
        handle.write("".join(result_parts))


def find_rectangular_edges(board):
    edge_lines = []
    for drawing in iter_drawings(board):
        if drawing.GetLayerName() != "Edge.Cuts" or not hasattr(drawing, "GetStart"):
            continue
        start = drawing.GetStart()
        end = drawing.GetEnd()
        sx, sy = to_mm(start.x), to_mm(start.y)
        ex, ey = to_mm(end.x), to_mm(end.y)
        edge_lines.append((drawing, sx, sy, ex, ey))

    if len(edge_lines) < 4:
        raise RuntimeError("Could not find a simple rectangular outline on Edge.Cuts.")

    xs = []
    ys = []
    for _, sx, sy, ex, ey in edge_lines:
        xs.extend([sx, ex])
        ys.extend([sy, ey])

    left = min(xs)
    right = max(xs)
    top = min(ys)
    bottom = max(ys)

    vertical = []
    horizontal = []
    for drawing, sx, sy, ex, ey in edge_lines:
        if abs(sx - ex) < 1e-6:
            vertical.append((drawing, sx))
        elif abs(sy - ey) < 1e-6:
            horizontal.append((drawing, sy))

    if len(vertical) < 2 or len(horizontal) < 2:
        raise RuntimeError("The Edge.Cuts outline is not a 4-segment rectangle.")

    left_line = min(vertical, key=lambda item: item[1])[0]
    right_line = max(vertical, key=lambda item: item[1])[0]
    top_line = min(horizontal, key=lambda item: item[1])[0]
    bottom_line = max(horizontal, key=lambda item: item[1])[0]

    return {
        "left": left,
        "right": right,
        "top": top,
        "bottom": bottom,
        "left_line": left_line,
        "right_line": right_line,
        "top_line": top_line,
        "bottom_line": bottom_line,
    }


def point_in_bbox(x_mm, y_mm, bbox):
    return bbox["left"] <= x_mm <= bbox["right"] and bbox["top"] <= y_mm <= bbox["bottom"]


def find_fixed_strip_bbox(board):
    xs = []
    ys = []
    for footprint in iter_footprints(board):
        if not FIXED_STRIP_JUMPER_RE.fullmatch(footprint.GetReference()):
            continue
        x_mm, y_mm = get_pos_mm(footprint)
        xs.append(x_mm)
        ys.append(y_mm)

    if not xs:
        return None

    return {
        "left": min(xs) - 2.5,
        "right": max(xs) + 2.5,
        "top": min(ys) - 6.5,
        "bottom": max(ys) + 22.5,
    }


def item_belongs_to_fixed_strip(item, fixed_strip_bbox):
    if fixed_strip_bbox is None:
        return False

    if isinstance(item, pcbnew.PCB_VIA):
        x_mm, y_mm = get_pos_mm(item)
        return point_in_bbox(x_mm, y_mm, fixed_strip_bbox)

    if isinstance(item, pcbnew.PCB_TRACK):
        sx_mm, sy_mm, ex_mm, ey_mm = get_track_endpoints_mm(item)
        return point_in_bbox(sx_mm, sy_mm, fixed_strip_bbox) and point_in_bbox(ex_mm, ey_mm, fixed_strip_bbox)

    if hasattr(item, "GetStart") and hasattr(item, "GetEnd"):
        start = item.GetStart()
        end = item.GetEnd()
        return point_in_bbox(to_mm(start.x), to_mm(start.y), fixed_strip_bbox) and point_in_bbox(
            to_mm(end.x), to_mm(end.y), fixed_strip_bbox
        )

    x_mm, y_mm = get_bbox_center_mm(item)
    return point_in_bbox(x_mm, y_mm, fixed_strip_bbox)


def move_fixed_strip_group(board, fixed_strip_bbox, dx_mm):
    if fixed_strip_bbox is None or abs(dx_mm) < 1e-9:
        return

    for footprint in iter_footprints(board):
        if FIXED_STRIP_JUMPER_RE.fullmatch(footprint.GetReference()):
            move_item_mm(footprint, dx_mm, 0.0)

    for track in iter_tracks(board):
        if not item_belongs_to_fixed_strip(track, fixed_strip_bbox):
            continue
        if isinstance(track, pcbnew.PCB_VIA):
            move_item_mm(track, dx_mm, 0.0)
        else:
            shift_track_rigid(track, dx_mm, 0.0)

    for zone in iter_zones(board):
        if item_belongs_to_fixed_strip(zone, fixed_strip_bbox):
            move_item_mm(zone, dx_mm, 0.0)

    for drawing in iter_drawings(board):
        if drawing.GetLayerName() == "Edge.Cuts" or not hasattr(drawing, "Move"):
            continue
        if item_belongs_to_fixed_strip(drawing, fixed_strip_bbox):
            move_item_mm(drawing, dx_mm, 0.0)


def compute_intervals(xs):
    intervals = []
    for index, x in enumerate(xs):
        left = float("-inf") if index == 0 else (xs[index - 1] + x) / 2
        right = float("inf") if index == len(xs) - 1 else (x + xs[index + 1]) / 2
        intervals.append((left, right))
    return intervals


def locate_channel(x_mm, intervals):
    for index, (left, right) in enumerate(intervals):
        if left <= x_mm < right:
            return index
    return None


def endpoint_delta_mm(x_mm, y_mm, intervals, deltas_by_channel, channel_top, channel_bottom):
    if not (channel_top <= y_mm <= channel_bottom):
        return 0.0
    channel = locate_channel(x_mm, intervals)
    if channel is None:
        return 0.0
    return deltas_by_channel[channel]


def move_track_parametric(track, intervals, deltas_by_channel, channel_top, channel_bottom, extra_right_margin_mm):
    sx_mm, sy_mm, ex_mm, ey_mm = get_track_endpoints_mm(track)
    start_dx = endpoint_delta_mm(sx_mm, sy_mm, intervals, deltas_by_channel, channel_top, channel_bottom)
    end_dx = endpoint_delta_mm(ex_mm, ey_mm, intervals, deltas_by_channel, channel_top, channel_bottom)
    center_dx = endpoint_delta_mm((sx_mm + ex_mm) / 2, (sy_mm + ey_mm) / 2, intervals, deltas_by_channel, channel_top, channel_bottom)

    is_horizontal = abs(sy_mm - ey_mm) < 0.05 and abs(sx_mm - ex_mm) > 0.2
    length_mm = ((ex_mm - sx_mm) ** 2 + (ey_mm - sy_mm) ** 2) ** 0.5
    right_margin_dx = extra_right_margin_mm if track.GetLayerName() == "F.Cu" else 0.0
    right_fanout_dx = deltas_by_channel[-1] + right_margin_dx
    in_upper_bus_band = max(sy_mm, ey_mm) <= FIXED_BUS_VIA_Y_MAX_MM

    start_in_left_fanout = sx_mm <= LEFT_FANOUT_X_MAX_MM
    end_in_left_fanout = ex_mm <= LEFT_FANOUT_X_MAX_MM
    start_in_left_local_fanout = sx_mm <= LEFT_LOCAL_FANOUT_X_MAX_MM
    end_in_left_local_fanout = ex_mm <= LEFT_LOCAL_FANOUT_X_MAX_MM
    start_in_right_fanout = sx_mm >= RIGHT_FANOUT_X_MIN_MM
    end_in_right_fanout = ex_mm >= RIGHT_FANOUT_X_MIN_MM
    is_right_connector_signal = track.GetLayerName() == "F.Cu" and track.GetNetname().startswith("/Pin_")
    is_right_vcc_fanout = (
        track.GetLayerName() == "F.Cu"
        and track.GetNetname() == "VCC"
        and not is_horizontal
        and (start_in_right_fanout or end_in_right_fanout)
    )

    if start_in_left_local_fanout and end_in_left_local_fanout:
        return

    if in_upper_bus_band and start_in_left_fanout and end_in_left_fanout:
        return

    if in_upper_bus_band and start_in_right_fanout and end_in_right_fanout:
        shift_track_rigid(track, right_fanout_dx, 0.0)
        return

    if is_horizontal and length_mm >= BUS_TRACK_MIN_LENGTH_MM:
        if start_in_left_fanout:
            start_dx = 0.0
        if end_in_left_fanout:
            end_dx = 0.0
        if start_in_right_fanout:
            start_dx = right_fanout_dx
        if end_in_right_fanout:
            end_dx = right_fanout_dx

        if abs(start_dx) < 1e-9 and abs(end_dx) < 1e-9:
            return

        track.SetStart(vector_mm(sx_mm + start_dx, sy_mm))
        track.SetEnd(vector_mm(ex_mm + end_dx, ey_mm))
        return

    if is_horizontal and length_mm >= LOCAL_HORIZONTAL_EXTENSION_MIN_MM and not in_upper_bus_band:
        if abs(start_dx - end_dx) >= 0.001:
            track.SetStart(vector_mm(sx_mm + start_dx, sy_mm))
            track.SetEnd(vector_mm(ex_mm + end_dx, ey_mm))
            return

    if in_upper_bus_band and (start_in_left_fanout or end_in_left_fanout):
        return

    if in_upper_bus_band and (start_in_right_fanout or end_in_right_fanout):
        shift_track_rigid(track, right_fanout_dx, 0.0)
        return

    if is_right_vcc_fanout:
        shift_track_rigid(track, right_fanout_dx, 0.0)
        return

    if abs(center_dx) < 1e-9:
        return

    shift_track_rigid(track, center_dx, 0.0)


def shift_right_fanout_residuals(board, old_right_edge_mm, right_fanout_dx):
    for track in iter_tracks(board):
        if isinstance(track, pcbnew.PCB_VIA) or track.GetLayerName() != "F.Cu":
            continue
        sx_mm, _, ex_mm, _ = get_track_endpoints_mm(track)
        if sx_mm >= RIGHT_FANOUT_X_MIN_MM and ex_mm >= RIGHT_FANOUT_X_MIN_MM:
            if sx_mm <= old_right_edge_mm and ex_mm <= old_right_edge_mm:
                shift_track_rigid(track, right_fanout_dx, 0.0)


def move_right_edge_aux_holes(source_holes, source_right_edge, right_edge):
    for footprint, source_x_mm, source_y_mm in source_holes:
        current_x_mm, current_y_mm = get_pos_mm(footprint)
        target_x = right_edge - (source_right_edge - source_x_mm)
        move_item_mm(footprint, target_x - current_x_mm, source_y_mm - current_y_mm)


def move_right_connector_signal_clusters(board, extra_right_margin_mm):
    if abs(extra_right_margin_mm) < 1e-9:
        return

    eligible = {}
    by_net = {}
    for track in iter_tracks(board):
        if isinstance(track, pcbnew.PCB_VIA) or track.GetLayerName() != "F.Cu":
            continue
        net_name = track.GetNetname()
        if not net_name.startswith("/Pin_"):
            continue

        sx_mm, sy_mm, ex_mm, ey_mm = get_track_endpoints_mm(track)
        if min(sy_mm, ey_mm) <= FIXED_BUS_VIA_Y_MAX_MM:
            continue
        if max(sy_mm, ey_mm) > RIGHT_FANOUT_SIGNAL_Y_MAX_MM:
            continue
        if min(sx_mm, ex_mm) < RIGHT_CONNECTOR_CLUSTER_X_MIN_MM:
            continue

        info = {
            "track": track,
            "id": item_key(track),
            "start": (sx_mm, sy_mm),
            "end": (ex_mm, ey_mm),
        }
        eligible[info["id"]] = info
        by_net.setdefault(track.GetNetCode(), []).append(info)

    moved_ids = set()
    for net_infos in by_net.values():
        seed_infos = [
            info
            for info in net_infos
            if abs(info["start"][1] - info["end"][1]) >= 0.05
            and max(info["start"][0], info["end"][0]) >= RIGHT_FANOUT_X_MIN_MM
        ]
        if not seed_infos:
            continue

        frontier = []
        visited = set()
        for info in seed_infos:
            visited.add(info["id"])
            frontier.extend((info["start"], info["end"]))

        cluster = list(seed_infos)
        while frontier:
            point = frontier.pop()
            for info in net_infos:
                if info["id"] in visited:
                    continue
                if not (
                    points_close(point, info["start"], tolerance_mm=0.12)
                    or points_close(point, info["end"], tolerance_mm=0.12)
                ):
                    continue
                visited.add(info["id"])
                cluster.append(info)
                frontier.extend((info["start"], info["end"]))

        for info in cluster:
            if info["id"] in moved_ids:
                continue
            shift_track_rigid(info["track"], extra_right_margin_mm, 0.0)
            moved_ids.add(info["id"])


def find_matching_vertical_track(board, net_name, y_mm, target_x_mm):
    candidates = []
    for track in iter_tracks(board):
        if isinstance(track, pcbnew.PCB_VIA) or track.GetLayerName() != "B.Cu":
            continue
        if track.GetNetname() != net_name:
            continue
        sx_mm, sy_mm, ex_mm, ey_mm = get_track_endpoints_mm(track)
        if abs(sx_mm - ex_mm) >= 0.05:
            continue
        length_mm = abs(sy_mm - ey_mm)
        if length_mm < 1.0:
            continue
        if min(sy_mm, ey_mm) - 0.2 <= y_mm <= max(sy_mm, ey_mm) + 0.2:
            candidates.append((abs(sx_mm - target_x_mm), -length_mm, sx_mm, track))

    if not candidates:
        return None, None

    _, _, x_mm, track = min(candidates, key=lambda item: (item[0], item[1]))
    return x_mm, track


def points_close(point_a, point_b, tolerance_mm=0.08):
    return abs(point_a[0] - point_b[0]) < tolerance_mm and abs(point_a[1] - point_b[1]) < tolerance_mm


def item_key(item):
    if hasattr(item, "GetUuid"):
        return str(item.GetUuid())
    return str(id(item))


def move_vias_for_points(board, net_code, points, dx_mm):
    moved_via_ids = set()
    for track in iter_tracks(board):
        if not isinstance(track, pcbnew.PCB_VIA):
            continue
        if track.GetNetCode() != net_code:
            continue
        via_id = item_key(track)
        if via_id in moved_via_ids:
            continue
        via_point = get_pos_mm(track)
        if any(points_close(via_point, point) for point in points):
            move_item_mm(track, dx_mm, 0.0)
            moved_via_ids.add(via_id)


def move_tail_stub_and_vias(board, vertical_track, old_tail_point, dx_mm):
    net_code = vertical_track.GetNetCode()
    move_vias_for_points(board, net_code, (old_tail_point,), dx_mm)

    for track in iter_tracks(board):
        if isinstance(track, pcbnew.PCB_VIA):
            continue
        if track.GetLayerName() != "B.Cu":
            continue
        if track.GetNetCode() != net_code:
            continue
        if item_key(track) == item_key(vertical_track):
            continue

        sx_mm, sy_mm, ex_mm, ey_mm = get_track_endpoints_mm(track)
        start_point = (sx_mm, sy_mm)
        end_point = (ex_mm, ey_mm)
        if not points_close(start_point, old_tail_point) and not points_close(end_point, old_tail_point):
            continue

        shift_track_rigid(track, dx_mm, 0.0)
        move_vias_for_points(board, net_code, (start_point, end_point), dx_mm)


def align_strip_verticals_to_jumpers(board):
    for footprint in iter_footprints(board):
        ref = footprint.GetReference()
        if not FIXED_STRIP_JUMPER_RE.fullmatch(ref):
            continue

        pad = next((pad for pad in footprint.Pads() if pad.GetNumber() == "2"), None)
        if pad is None:
            continue

        net_name = pad.GetNetname()
        if not net_name:
            continue

        pad_pos = pad.GetPosition()
        pad_x_mm = to_mm(pad_pos.x)
        pad_y_mm = to_mm(pad_pos.y)
        vertical_x_mm, vertical_track = find_matching_vertical_track(board, net_name, pad_y_mm, pad_x_mm)
        if vertical_track is None or abs(vertical_x_mm - pad_x_mm) < 0.001:
            continue

        dx_mm = pad_x_mm - vertical_x_mm
        _, sy_mm, _, ey_mm = get_track_endpoints_mm(vertical_track)
        tail_y_mm = max(sy_mm, ey_mm)
        old_tail_point = (vertical_x_mm, tail_y_mm)
        shift_track_rigid(vertical_track, dx_mm, 0.0)
        move_tail_stub_and_vias(board, vertical_track, old_tail_point, dx_mm)


def redefine_power_planes(board, left_edge, right_edge, board_top, board_bottom):
    plane_nets = {"GND", "VDD"}
    rectangle = [
        (left_edge + PLANE_MARGIN_MM, board_top + PLANE_MARGIN_MM),
        (right_edge - PLANE_MARGIN_MM, board_top + PLANE_MARGIN_MM),
        (right_edge - PLANE_MARGIN_MM, board_bottom - PLANE_MARGIN_MM),
        (left_edge + PLANE_MARGIN_MM, board_bottom - PLANE_MARGIN_MM),
    ]

    for zone in iter_zones(board):
        if zone.GetNetname() not in plane_nets:
            continue
        outline = zone.Outline()
        outline.RemoveAllContours()
        outline.NewOutline()
        for x_mm, y_mm in rectangle:
            outline.Append(vector_mm(x_mm, y_mm))
        zone.UnFill()
        zone.SetIsFilled(False)


def refill_all_zones(board):
    pcbnew.ZONE_FILLER(board).Fill(board.Zones())


def find_dimension_by_text(board, text):
    for drawing in iter_drawings(board):
        if type(drawing).__name__ != "PCB_DIM_ORTHOGONAL":
            continue
        if drawing.GetText() == text:
            return drawing
    return None


def configure_dimension_common(dimension, layer_id):
    dimension.SetLayer(layer_id)
    dimension.SetUnitsMode(3)
    dimension.SetUnits(1)
    dimension.SetTextPositionMode(0)
    dimension.SetTextSize(vector_mm(1.5, 1.5))
    dimension.SetTextThickness(mm(0.3))
    dimension.SetExtensionHeight(mm(0.58642))


def update_user_dimensions(
    board,
    source_right_edge,
    left_edge,
    right_edge,
    board_top,
    board_bottom,
    speaker_positions,
    speaker_width_mm,
    speaker_spacing_mm,
):
    board_width_mm = right_edge - left_edge
    board_height_mm = board_bottom - board_top
    width_dim = find_dimension_by_text(board, "190")
    if width_dim is not None:
        width_dim.SetStart(vector_mm(left_edge, board_top))
        width_dim.SetEnd(vector_mm(right_edge, board_top))
        width_dim.SetHeight(mm(-10.8))
        width_dim.SetOverrideText(f"{board_width_mm:.2f}")
        width_dim.SetOverrideTextEnabled(True)
        width_dim.SetTextPos(vector_mm((left_edge + right_edge) / 2, board_top - 12.6))

    height_dim = find_dimension_by_text(board, "90")
    if height_dim is not None:
        height_dim.SetStart(vector_mm(left_edge, board_top))
        height_dim.SetEnd(vector_mm(left_edge, board_bottom))
        height_dim.SetHeight(mm(-9.3))
        height_dim.SetOverrideText(f"{board_height_mm:.0f}")
        height_dim.SetOverrideTextEnabled(True)
        height_dim.SetTextPos(vector_mm(left_edge - 11.1, (board_top + board_bottom) / 2))

    one_mm_dim = find_dimension_by_text(board, "1")
    if one_mm_dim is not None:
        start_x_offset_mm = 0.93
        end_x_offset_mm = 1.93
        y_offset_top_mm = 3.29
        one_mm_dim.SetStart(vector_mm(right_edge + start_x_offset_mm, board_bottom - y_offset_top_mm))
        one_mm_dim.SetEnd(vector_mm(right_edge + end_x_offset_mm, board_bottom - y_offset_top_mm + 0.02))
        one_mm_dim.SetHeight(mm(6.48))
        one_mm_dim.SetOverrideText("1")
        one_mm_dim.SetOverrideTextEnabled(True)
        one_mm_dim.SetTextPos(vector_mm(right_edge + 2.4, board_bottom + 1.39))

    if len(speaker_positions) < 2:
        return

    ls1_x_mm, ls1_y_mm = speaker_positions[0]
    ls2_x_mm, ls2_y_mm = speaker_positions[1]
    reference_dim = width_dim or height_dim or one_mm_dim
    layer_id = reference_dim.GetLayer() if reference_dim is not None else 39

    width_speaker_dim = find_dimension_by_text(board, f"{speaker_width_mm:.2f}")
    if width_speaker_dim is None:
        width_speaker_dim = pcbnew.PCB_DIM_ORTHOGONAL(board)
        configure_dimension_common(width_speaker_dim, layer_id)
        board.Add(width_speaker_dim)

    width_start_x_mm = ls1_x_mm 
    width_end_x_mm = ls1_x_mm + speaker_width_mm
    width_speaker_dim.SetStart(vector_mm(width_start_x_mm, ls1_y_mm))
    width_speaker_dim.SetEnd(vector_mm(width_end_x_mm, ls1_y_mm))
    width_speaker_dim.SetHeight(mm(-18.0))
    width_speaker_dim.SetOverrideText(f"{speaker_width_mm:.2f}")
    width_speaker_dim.SetOverrideTextEnabled(True)
    width_speaker_dim.SetTextPos(vector_mm((width_start_x_mm + width_end_x_mm) / 2, ls1_y_mm - 19.8))

    spacing_dim = find_dimension_by_text(board, f"{speaker_spacing_mm:.2f}")
    if spacing_dim is None:
        spacing_dim = pcbnew.PCB_DIM_ORTHOGONAL(board)
        configure_dimension_common(spacing_dim, layer_id)
        board.Add(spacing_dim)

    spacing_start_x_mm = ls1_x_mm + speaker_width_mm
    spacing_end_x_mm = ls2_x_mm
    spacing_dim.SetStart(vector_mm(spacing_start_x_mm, ls1_y_mm))
    spacing_dim.SetEnd(vector_mm(spacing_end_x_mm, ls2_y_mm))
    spacing_dim.SetHeight(mm(-23.5))
    spacing_dim.SetOverrideText(f"{speaker_spacing_mm:.2f}")
    spacing_dim.SetOverrideTextEnabled(True)
    spacing_dim.SetTextPos(vector_mm((spacing_start_x_mm + spacing_end_x_mm) / 2, ls1_y_mm - 25.3))


def compute_bottom_silk_split_x(board):
    text_left_edges = []
    for drawing in iter_drawings(board):
        if drawing.GetLayerName() != "B.Silkscreen":
            continue
        if type(drawing).__name__ != "PCB_TEXT":
            continue
        bbox = drawing.GetBoundingBox()
        x_mm = to_mm(bbox.GetX())
        y_mm = to_mm(bbox.GetY())
        if x_mm < 100.0 or y_mm > 75.0:
            continue
        text_left_edges.append(x_mm)

    if text_left_edges:
        return min(text_left_edges)
    return None


def move_bottom_silkscreen_groups(board, source_left_edge, source_right_edge, left_edge, right_edge):
    split_x_mm = compute_bottom_silk_split_x(board)
    if split_x_mm is None:
        split_x_mm = (source_left_edge + source_right_edge) / 2

    left_dx_mm = left_edge - source_left_edge
    right_dx_mm = right_edge - source_right_edge

    for drawing in iter_drawings(board):
        if drawing.GetLayerName() != "B.Silkscreen" or not hasattr(drawing, "Move"):
            continue

        bbox = drawing.GetBoundingBox()
        x_mm = to_mm(bbox.GetX())
        width_mm = to_mm(bbox.GetWidth())
        height_mm = to_mm(bbox.GetHeight())
        center_x_mm = x_mm + width_mm / 2

        is_large_logo_shape = (
            type(drawing).__name__ == "PCB_SHAPE"
            and (width_mm >= BOTTOM_SILK_LOGO_MIN_SIZE_MM or height_mm >= BOTTOM_SILK_LOGO_MIN_SIZE_MM)
            and x_mm < split_x_mm + 20.0
        )

        if is_large_logo_shape or center_x_mm < split_x_mm:
            move_item_mm(drawing, left_dx_mm, 0.0)
        else:
            text_value = getattr(drawing, "GetText", lambda: None)()
            if text_value in {"The LINE.", "POLYPHONIC", "CHANNEL"}:
                continue
            if text_value is not None and text_value.isdigit():
                continue
            move_item_mm(drawing, right_dx_mm, 0.0)


def set_rectangle_edges(edge_info, left, right, top, bottom):
    edge_info["left_line"].SetStart(vector_mm(left, top))
    edge_info["left_line"].SetEnd(vector_mm(left, bottom))
    edge_info["top_line"].SetStart(vector_mm(left, top))
    edge_info["top_line"].SetEnd(vector_mm(right, top))
    edge_info["bottom_line"].SetStart(vector_mm(right, bottom))
    edge_info["bottom_line"].SetEnd(vector_mm(left, bottom))
    edge_info["right_line"].SetStart(vector_mm(right, bottom))
    edge_info["right_line"].SetEnd(vector_mm(right, top))


def footprint_is_parametric_candidate(footprint):
    ref = footprint.GetReference()
    if ref in CONNECTOR_REFS or ref in FIXED_LEFT_AUX_REFS or ref in U8_LOCAL_JUMPERS:
        return False
    if FIXED_STRIP_JUMPER_RE.fullmatch(ref):
        return False
    library_id = str(footprint.GetFPID().GetUniStringLibId())
    return not library_id.startswith(EXCLUDED_FP_PREFIXES)


def build_parser():
    parser = argparse.ArgumentParser(
        description=(
            "Generate the parametric version of the TheLine PCB from the KiCad template."
        )
    )
    parser.add_argument("--input", default="../TheLine.kicad_pcb", help="Template PCB file.")
    parser.add_argument("--output", default="TheLine_parametric.kicad_pcb", help="Generated PCB file.")
    parser.add_argument(
        "--custom-footprint",
        help="Path to a .kicad_pcb file whose first footprint will replace every LS* speaker footprint.",
    )
    parser.add_argument(
        "--speaker-width",
        type=float,
        default=23.0,
        help="Width of one speaker/ADC block.",
    )
    parser.add_argument(
        "--speaker-spacing",
        type=float,
        default=2.0,
        help="Gap between two adjacent blocks. Default: 2.0 mm.",
    )
    parser.add_argument(
        "--speaker-height",
        type=min_90,
        default=90.0,
        help="Height of PCB (min 90 mm)",
    )
    parser.add_argument("--dry-run", action="store_true", help="Do not write the output file.")
    return parser
def min_90(value):

    v = float(value)

    if v < 90:
        raise argparse.ArgumentTypeError(
            "speaker-height must be ≥ 90 mm"
        )

    return v

def main():
    args = build_parser().parse_args()

    board = load_board(args.input)
    edge_info = find_rectangular_edges(board)
    fixed_strip_bbox = find_fixed_strip_bbox(board)
    speakers = find_speakers(board)

    template_positions = {}
    for ref in (*FIXED_LEFT_AUX_REFS, "U8", *U8_LOCAL_JUMPERS):
        template_positions[ref] = get_pos_mm(find_footprint_or_die(board, ref))
    right_edge_aux_holes = [
        (footprint, *get_pos_mm(footprint))
        for footprint in iter_footprints(board)
        if not footprint.GetReference() and get_pos_mm(footprint)[0] >= edge_info["right"] - 5.0
    ]

    speaker_footprints = [footprint for _, footprint in speakers]
    current_speaker_xs = [get_pos_mm(footprint)[0] for footprint in speaker_footprints]
    current_speaker_ys = [get_pos_mm(footprint)[1] for footprint in speaker_footprints]

    if len(current_speaker_xs) < 2:
        raise RuntimeError("At least 2 speakers are required to infer the spacing.")

    default_pitch = sum(
        current_speaker_xs[index + 1] - current_speaker_xs[index]
        for index in range(len(current_speaker_xs) - 1)
    ) / (len(current_speaker_xs) - 1)

    speaker_start_x = current_speaker_xs[0]
    speaker_y = sum(current_speaker_ys) / len(current_speaker_ys)
    speaker_spacing_mm = args.speaker_spacing
    template_speaker_width_mm = default_pitch - speaker_spacing_mm
    if args.speaker_width is not None:
        speaker_width_mm = args.speaker_width
        speaker_pitch = speaker_width_mm + speaker_spacing_mm
    else:
        speaker_pitch = default_pitch
        speaker_width_mm = template_speaker_width_mm

    desired_speaker_xs = [speaker_start_x + index * speaker_pitch for index in range(len(speaker_footprints))]
    desired_speaker_positions = [(desired_speaker_xs[index], speaker_y) for index in range(len(speaker_footprints))]
    deltas_by_channel = [
        desired_speaker_xs[index] - current_speaker_xs[index]
        for index in range(len(speaker_footprints))
    ]

    u_ys = []
    for footprint in iter_footprints(board):
        if footprint.GetReference().startswith("U"):
            _, y_mm = get_pos_mm(footprint)
            u_ys.append(y_mm)

    default_channel_top = min(min(current_speaker_ys), min(u_ys) if u_ys else min(current_speaker_ys)) - 12.0
    default_channel_bottom = max(max(current_speaker_ys), max(u_ys) if u_ys else max(current_speaker_ys)) + 12.0
    channel_top = default_channel_top
    channel_bottom = default_channel_bottom

    left_edge = edge_info["left"]
    template_right_clearance = edge_info["right"] - current_speaker_xs[-1]
    extra_right_margin_mm = speaker_width_mm - template_speaker_width_mm
    parametric_right_edge = desired_speaker_xs[-1] + template_right_clearance
    right_edge = parametric_right_edge + extra_right_margin_mm
    board_top = edge_info["top"]
    board_bottom = edge_info["bottom"]
    fixed_strip_dx = parametric_right_edge - edge_info["right"]
    center_y = (edge_info["top"] + edge_info["bottom"]) / 2
    if args.speaker_height is not None:
        top_edge=center_y - args.speaker_height / 2
        bottom_edge= center_y + args.speaker_height / 2
    else:
        top_edge=board_top
        bottom_edge= board_bottom

    intervals = compute_intervals(current_speaker_xs)

    for footprint in iter_footprints(board):
        if not footprint_is_parametric_candidate(footprint):
            continue
        x_mm, y_mm = get_pos_mm(footprint)
        if not (channel_top <= y_mm <= channel_bottom):
            continue
        channel = locate_channel(x_mm, intervals)
        if channel is None:
            continue
        dy_mm = speaker_y - y_mm if footprint in speaker_footprints else 0.0
        move_item_mm(footprint, deltas_by_channel[channel], dy_mm)

    for track in iter_tracks(board):
        if isinstance(track, pcbnew.PCB_VIA):
            _, via_y_mm = get_pos_mm(track)
            if via_y_mm <= FIXED_BUS_VIA_Y_MAX_MM:
                continue
        if item_belongs_to_fixed_strip(track, fixed_strip_bbox):
            continue
        move_track_parametric(track, intervals, deltas_by_channel, channel_top, channel_bottom, extra_right_margin_mm)

    for zone in iter_zones(board):
        if item_belongs_to_fixed_strip(zone, fixed_strip_bbox):
            continue
        x_mm, y_mm = get_bbox_center_mm(zone)
        if not (channel_top <= y_mm <= channel_bottom):
            continue
        channel = locate_channel(x_mm, intervals)
        if channel is None:
            continue
        move_item_mm(zone, deltas_by_channel[channel], 0.0)

    for drawing in iter_drawings(board):
        if drawing.GetLayerName() in {"Edge.Cuts", "B.Silkscreen"} or not hasattr(drawing, "Move"):
            continue
        if item_belongs_to_fixed_strip(drawing, fixed_strip_bbox):
            continue
        x_mm, y_mm = get_bbox_center_mm(drawing)
        if not (channel_top <= y_mm <= channel_bottom):
            continue
        channel = locate_channel(x_mm, intervals)
        if channel is None:
            continue
        move_item_mm(drawing, deltas_by_channel[channel], 0.0)

    shift_right_fanout_residuals(board, edge_info["right"], deltas_by_channel[-1] + extra_right_margin_mm)
    move_right_connector_signal_clusters(board, extra_right_margin_mm)
    move_fixed_strip_group(board, fixed_strip_bbox, fixed_strip_dx)

    for ref in ("J1", "J2"):
        footprint = board.FindFootprintByReference(ref)
        if footprint is None:
            continue
        x_mm, _ = get_pos_mm(footprint)
        target_x = left_edge + (x_mm - edge_info["left"])
        move_item_mm(footprint, target_x - x_mm, 0.0)

    for ref in ("J3", "J4"):
        footprint = board.FindFootprintByReference(ref)
        if footprint is None:
            continue
        x_mm, _ = get_pos_mm(footprint)
        target_x = right_edge - (edge_info["right"] - x_mm)
        move_item_mm(footprint, target_x - x_mm, 0.0)
    move_right_edge_aux_holes(right_edge_aux_holes, edge_info["right"], right_edge)

    for ref in FIXED_LEFT_AUX_REFS:
        footprint = find_footprint_or_die(board, ref)
        target_x, target_y = template_positions[ref]
        x_mm, y_mm = get_pos_mm(footprint)
        move_item_mm(footprint, target_x - x_mm, target_y - y_mm)

    u8 = find_footprint_or_die(board, "U8")
    u8_target_x, u8_target_y = get_pos_mm(u8)
    u8_base_x, u8_base_y = template_positions["U8"]
    for ref in U8_LOCAL_JUMPERS:
        footprint = find_footprint_or_die(board, ref)
        base_x, base_y = template_positions[ref]
        target_x = u8_target_x + (base_x - u8_base_x)
        target_y = u8_target_y + (base_y - u8_base_y)
        x_mm, y_mm = get_pos_mm(footprint)
        move_item_mm(footprint, target_x - x_mm, target_y - y_mm)

    align_strip_verticals_to_jumpers(board)
    update_user_dimensions(
        board,
        edge_info["right"],
        left_edge,
        right_edge,
        top_edge,
        bottom_edge,
        desired_speaker_positions,
        speaker_width_mm,
        speaker_spacing_mm,
    )
    move_bottom_silkscreen_groups(board, edge_info["left"], edge_info["right"], left_edge, right_edge)
    redefine_power_planes(board, left_edge, right_edge, top_edge, bottom_edge)
    set_rectangle_edges(edge_info, left_edge, right_edge,  top_edge,bottom_edge)
    refill_all_zones(board)
    draw_all_speaker_outlines(
        board,
        desired_speaker_positions,
        speaker_width_mm,
        args.speaker_height,
        bottom_edge
    )
    print(f"PCB source         : {args.input}")
    print(f"PCB output         : {args.output}")
    print(f"Channel Number   : {len(speaker_footprints)}")
    print(f"LS1 X              : {speaker_start_x:.3f} mm")
    print(f"Speaker width      : {speaker_width_mm:.3f} mm")
    print(f"Speaker spacing    : {speaker_spacing_mm:.3f} mm")
    print(f"Y Band : {channel_top:.3f} -> {channel_bottom:.3f} mm")
    print(f"Edge            : left={left_edge:.3f} right={right_edge:.3f} top={board_top:.3f} bottom={board_bottom:.3f} mm")

    if not args.dry_run:
        if args.custom_footprint:
            import_custom_block(board, args.custom_footprint)
        pcbnew.SaveBoard(args.output, board)
        print("Parametric PCB generated!")
    else:
        print("Dry-run termine, aucun fichier ecrit.")

def draw_rounded_rect_silk(
    board,
    center_x,
    center_y,
    width,
    height,
    radius=1.5,
    line_width=0.15,
    layer="F.Silkscreen",
):

    r = min(radius, width/2 - 0.01, height/2 - 0.01)


    left = center_x
    right = center_x + width
    top = center_y- height
    bottom = center_y

    layer_id = board.GetLayerID(layer)

    def add_line(x1,y1,x2,y2):

        line = pcbnew.PCB_SHAPE(board)
        line.SetShape(pcbnew.SHAPE_T_SEGMENT)
        line.SetLayer(layer_id)
        line.SetWidth(mm(line_width))

        line.SetStart(vector_mm(x1,y1))
        line.SetEnd(vector_mm(x2,y2))

        board.Add(line)


    def add_arc(cx,cy,start_x,start_y,end_x,end_y):

        arc = pcbnew.PCB_SHAPE(board)
        arc.SetShape(pcbnew.SHAPE_T_ARC)
        arc.SetLayer(layer_id)
        arc.SetWidth(mm(line_width))

        arc.SetStart(vector_mm(start_x,start_y))
        arc.SetEnd(vector_mm(end_x,end_y))
        arc.SetCenter(vector_mm(cx,cy))

        board.Add(arc)


    # segments horizontaux
    add_line(left+r, top, right-r, top)
    add_line(left+r, bottom, right-r, bottom)

    # segments verticaux
    add_line(left, top+r, left, bottom-r)
    add_line(right, top+r, right, bottom-r)

    # coin haut gauche
    add_arc(
        left+r, top+r,
        left, top+r,
        left+r, top
    )

    # coin haut droit
    add_arc(
        right-r, top+r,
        right-r, top,
        right, top+r
    )

    # coin bas droit
    add_arc(
        right-r, bottom-r,
        right, bottom-r,
        right-r, bottom
    )

    # coin bas gauche
    add_arc(
        left+r, bottom-r,
        left+r, bottom,
        left, bottom-r
    )
def draw_all_speaker_outlines(
    board,
    speaker_positions,
    speaker_width,
    speaker_height,
    bottom_edge
):

    for x,y in speaker_positions:

        draw_rounded_rect_silk(
            board,
            x,
            bottom_edge,
            speaker_width,
            speaker_height,
            radius=3,
            line_width=0.15,
            layer="Dwgs.User",
        )
        draw_rounded_rect_silk(
            board,
            x+1,
            bottom_edge-1,
            speaker_width-2,
            speaker_height-2,
            radius=3,
            line_width=0.15,
            layer="F.Silkscreen",
        )

if __name__ == "__main__":
    main()
