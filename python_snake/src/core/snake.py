import pygame
import random
import math
from utils.constants import GameConstants

class Direction:
    NORTH = (0, -1)
    SOUTH = (0, 1)
    EAST = (1, 0)
    WEST = (-1, 0)

    @staticmethod
    def opposite(dir):
        if dir == Direction.NORTH: return Direction.SOUTH
        if dir == Direction.SOUTH: return Direction.NORTH
        if dir == Direction.EAST: return Direction.WEST
        if dir == Direction.WEST: return Direction.EAST
        return dir

class Snake:
    def __init__(self, x, y):
        self.is_alive = True
        self.invulnerability_timer = GameConstants.INVULNERABILITY_TIME
        self.score = 0
        self.food_counts = {}
        self.heading = Direction.NORTH
        self.next_heading = Direction.NORTH
        self.base_move_speed = GameConstants.INITIAL_MOVE_SPEED
        self.speed_multiplier = 1.0

        # Position in pixels (float)
        self.pos = pygame.Vector2(x, y)
        self.grid_distance = 0.0
        self.distance_traveled = 0.0

        # Number of segments
        self.num_segments = 2

        # History of transforms (pos and rot)
        self.position_history = []
        self._initialize_history()

        # Visual Juice
        self.head_scale = 1.0
        self.shake_offset = pygame.Vector2(0, 0)

    def _initialize_history(self):
        needed = (self.num_segments + 1) * GameConstants.SEGMENT_SPACING + 1
        for i in range(needed):
            pos = pygame.Vector2(self.pos.x, self.pos.y + i * GameConstants.HISTORY_RESOLUTION)
            self.position_history.append((pos, 0))

    def handle_input(self, keys):
        requested = self.heading
        if keys[pygame.K_UP] or keys[pygame.K_w]: requested = Direction.NORTH
        elif keys[pygame.K_DOWN] or keys[pygame.K_s]: requested = Direction.SOUTH
        elif keys[pygame.K_LEFT] or keys[pygame.K_a]: requested = Direction.WEST
        elif keys[pygame.K_RIGHT] or keys[pygame.K_d]: requested = Direction.EAST
        else: return

        if requested != Direction.opposite(self.heading):
            self.next_heading = requested

    def update(self, delta_time):
        if not self.is_alive: return

        if self.invulnerability_timer > 0:
            self.invulnerability_timer -= delta_time

        self.move_forward(delta_time)
        self.check_collision()

        # Slerp scale back to 1.0
        self.head_scale = math.isclose(self.head_scale, 1.0, abs_tol=0.01) and 1.0 or self.head_scale + (1.0 - self.head_scale) * 10 * delta_time

    def move_forward(self, delta_time):
        forward = pygame.Vector2(self.heading[0], self.heading[1])
        move_speed = self.base_move_speed * self.speed_multiplier
        move_vec = forward * move_speed * delta_time

        self.pos += move_vec
        step = move_vec.length()
        self.distance_traveled += step
        self.grid_distance += step

        if self.grid_distance >= GameConstants.GRID_SIZE:
            self.grid_distance -= GameConstants.GRID_SIZE
            self.pos.x = round(self.pos.x / GameConstants.GRID_SIZE) * GameConstants.GRID_SIZE
            self.pos.y = round(self.pos.y / GameConstants.GRID_SIZE) * GameConstants.GRID_SIZE

            if self.next_heading != self.heading:
                self.heading = self.next_heading

        if self.distance_traveled >= GameConstants.HISTORY_RESOLUTION:
            self.distance_traveled -= GameConstants.HISTORY_RESOLUTION
            rotation = 0
            if self.heading == Direction.NORTH: rotation = 0
            elif self.heading == Direction.SOUTH: rotation = 180
            elif self.heading == Direction.EAST: rotation = 90
            elif self.heading == Direction.WEST: rotation = 270

            self.position_history.insert(0, (pygame.Vector2(self.pos), rotation))

            max_history = (self.num_segments + 1) * GameConstants.SEGMENT_SPACING + 1
            if len(self.position_history) > max_history:
                self.position_history = self.position_history[:max_history]

    def check_collision(self):
        # Wall collision
        if (self.pos.x < 0 or self.pos.x >= GameConstants.BOARD_WIDTH or
            self.pos.y < 0 or self.pos.y >= GameConstants.BOARD_HEIGHT):
            self.die("Wall collision")
            return

        # Self collision
        if self.invulnerability_timer <= 0:
            head_rect = pygame.Rect(self.pos.x, self.pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
            for i in range(1, self.num_segments + 1):
                idx = i * GameConstants.SEGMENT_SPACING
                if idx < len(self.position_history):
                    seg_pos, _ = self.position_history[idx]
                    seg_rect = pygame.Rect(seg_pos.x, seg_pos.y, GameConstants.GRID_SIZE, GameConstants.GRID_SIZE)
                    seg_rect.inflate_ip(-GameConstants.GRID_SIZE * 0.4, -GameConstants.GRID_SIZE * 0.4)
                    if head_rect.colliderect(seg_rect):
                        self.die("Self collision")
                        return

    def die(self, reason):
        if not self.is_alive: return
        self.is_alive = False
        print(f"Snake died: {reason}")

    def add_segment(self):
        self.num_segments += 1
        self.head_scale = 1.3 # Pop effect

    def draw(self, screen, shake_offset=(0,0)):
        # Draw segments from back to front
        for i in range(self.num_segments, 0, -1):
            idx = i * GameConstants.SEGMENT_SPACING
            if idx < len(self.position_history):
                pos, _ = self.position_history[idx]
                draw_pos = (pos.x + shake_offset[0], pos.y + shake_offset[1])
                pygame.draw.rect(screen, GameConstants.COLOR_SNAKE,
                                 (draw_pos[0], draw_pos[1], GameConstants.GRID_SIZE, GameConstants.GRID_SIZE),
                                 border_radius=8)

        # Draw head with scale
        h_size = GameConstants.GRID_SIZE * self.head_scale
        h_rect = pygame.Rect(0, 0, h_size, h_size)
        h_rect.center = (self.pos.x + GameConstants.GRID_SIZE//2 + shake_offset[0],
                         self.pos.y + GameConstants.GRID_SIZE//2 + shake_offset[1])

        pygame.draw.rect(screen, GameConstants.COLOR_SNAKE, h_rect, border_radius=12)

        # Eyes
        eye_color = (255, 255, 255)
        pupil_color = (0, 0, 0)

        # Scale eye offsets
        e_off = GameConstants.GRID_SIZE * 0.25 * self.head_scale
        e_size = 4 * self.head_scale

        # Relative positions based on heading
        p_l, p_r = pygame.Vector2(-e_off, -e_off), pygame.Vector2(e_off, -e_off)
        if self.heading == Direction.SOUTH: p_l, p_r = pygame.Vector2(-e_off, e_off), pygame.Vector2(e_off, e_off)
        elif self.heading == Direction.EAST: p_l, p_r = pygame.Vector2(e_off, -e_off), pygame.Vector2(e_off, e_off)
        elif self.heading == Direction.WEST: p_l, p_r = pygame.Vector2(-e_off, -e_off), pygame.Vector2(-e_off, e_off)

        pygame.draw.circle(screen, eye_color, (h_rect.centerx + p_l.x, h_rect.centery + p_l.y), e_size)
        pygame.draw.circle(screen, eye_color, (h_rect.centerx + p_r.x, h_rect.centery + p_r.y), e_size)
        pygame.draw.circle(screen, pupil_color, (h_rect.centerx + p_l.x, h_rect.centery + p_l.y), e_size//2)
        pygame.draw.circle(screen, pupil_color, (h_rect.centerx + p_r.x, h_rect.centery + p_r.y), e_size//2)

        if not self.is_alive:
            # Birdies / Dazed stars
            num_stars = 3
            radius = 30
            angle = pygame.time.get_ticks() * 0.01
            for i in range(num_stars):
                off_x = math.cos(angle + i * (2*math.pi/num_stars)) * radius
                off_y = math.sin(angle + i * (2*math.pi/num_stars)) * radius * 0.5
                pygame.draw.circle(screen, (255, 255, 0), (h_rect.centerx + off_x, h_rect.centery + off_y - 30), 4)
