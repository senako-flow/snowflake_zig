const std = @import("std");

pub const Error = error{
    ClockMovedBackward,
    SequenceExhausted,
};

pub const Option = struct {
    sign: u1,
    epoch: i64,

    pub const default = @This(){
        .sign = 0,
        .epoch = 1_577_836_800_000,
    };
};

pub const Snowflake = struct {
    sign: u1,

    timestamp: u64,
    worker_id: u10,

    sequence: u12,

    pub fn init(sign: u1, timestamp: u64, worker_id: u10, sequence: u12) @This() {
        return .{
            .sign = sign,
            .timestamp = timestamp,
            .worker_id = worker_id,
            .sequence = sequence,
        };
    }

    pub fn number(self: @This()) u64 {
        const sign = @as(u64, self.sign);
        const worker_id = @as(u64, self.worker_id);

        const sequence = @as(u64, self.sequence);

        return (sign << 63) | (self.timestamp << 22) | (worker_id << 12) | sequence;
    }

    pub fn string(self: @This(), allocator: std.mem.Allocator) ![]u8 {
        return try allocator.print("{d}", .{self.number()});
    }
};

pub const Node = struct {
    io: std.Io,
    mutex: std.Io.Mutex,

    sign: u1,
    epoch: i64,

    worker_id: u10,
    timestamp: i64,

    sequence: u12,

    pub fn init(io: std.Io, worker_id: u10, option: Option) @This() {
        return .{
            .io = io,
            .mutex = .init,
            .sign = option.sign,
            .epoch = option.epoch,
            .worker_id = worker_id,
            .timestamp = -1,
            .sequence = 0,
        };
    }

    pub fn generate(self: *@This()) !Snowflake {
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);

        const now = std.Io.Timestamp.now(self.io, .real).toMilliseconds();

        if (now < self.timestamp) {
            return Error.ClockMovedBackward;
        }

        const timestamp: u64 = @intCast(now - self.epoch);

        if (now != self.timestamp) {
            self.sequence = 0;
            self.timestamp = now;

            return Snowflake.init(self.sign, timestamp, self.worker_id, self.sequence);
        }

        if (self.sequence == std.math.maxInt(u12)) {
            return Error.SequenceExhausted;
        }

        self.sequence += 1;

        return Snowflake.init(self.sign, timestamp, self.worker_id, self.sequence);
    }
};
