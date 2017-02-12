use chrono::prelude::UTC;
use env_logger::LogBuilder;
use log::{LogRecord, LogLevelFilter};

pub fn init(verbosity_level: u64) {
    let format = |record: &LogRecord| {
        let dt = UTC::now();
        format!("[{}] [{}] - {}",
                dt.format("%Y-%m-%d %H:%M:%S").to_string(),
                record.level(),
                record.args())
    };

    let log_level_filter = match verbosity_level {
        // Normal verbosity (no verbose): WARN
        0 => LogLevelFilter::Warn,
        // Verbose mode: INFO
        1 => LogLevelFilter::Info,
        // More verbose mode: DEBUG
        3 => LogLevelFilter::Debug,
        // More verbose mode: TRACE
        4 | _ => LogLevelFilter::Trace,
    };

    let mut builder = LogBuilder::new();
    builder.format(format).filter(None, log_level_filter);
    builder.init().unwrap();
}