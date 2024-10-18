use std::str::FromStr;

/// Parse a specific report line at index <l>.
/// Returns line values in a vector of <T>,
/// filtering out values that cannot be parsed
pub fn line<T: FromStr>(s: &str, l: usize) -> Vec<T> {
    s.lines().nth(l).unwrap()
        .replace("|", " ").replace("%", " ")
        .split_whitespace()
        .filter_map(|s| s.parse::<T>().ok())
        .collect()
}

pub fn index_of(f: &str, pattern: &str) -> Option<usize> {
    f.lines().position(|s| s.starts_with(&pattern))
}

#[inline]
pub fn values<T: FromStr>(f: &str, pattern: &str) -> Option<Vec<T>> {
    if let Some(i) = index_of(&f, &pattern) {
        Some(line(&f, i))
    } else {
        None
    }
}
