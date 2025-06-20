const std = @import("std");

const rl = @import("raylib");

const models = @import("models.zig");

pub const EventType = enum {
    Tick,
    Frame,
};

pub const Event = union(EventType) {
    Tick: struct {
        allocator: std.mem.Allocator,

        balls: std.ArrayList(models.BallData),

        count: u128,
    },
    Frame: struct {
        allocator: std.mem.Allocator,

        rendering: struct {
            balls: std.ArrayList(models.BallData),
            shader: rl.Shader,
            batch: rl.gl.rlRenderBatch,
            use_instanced: bool,
            camera: rl.Camera2D,
        },
    },
};

pub const EventHandler = *const fn (event: Event) void;

const HandlerData = struct {
    handler: EventHandler,
    event_type: EventType,
};

pub const EventDispatcher = struct {
    handlers: std.ArrayList(HandlerData),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) EventDispatcher {
        return .{
            .handlers = std.ArrayList(HandlerData).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *EventDispatcher) void {
        self.handlers.deinit();
    }

    pub fn register(self: *EventDispatcher, handler: EventHandler, event: EventType) !void {
        try self.handlers.append(.{ .event_type = event, .handler = handler });
    }

    pub fn post(self: *EventDispatcher, event: Event, event_type: EventType) void {
        for (self.handlers.items) |entry| {
            if (entry.event_type == event_type) {
                entry.handler(event);
            }
        }
    }
};
