class GameConstants:
    # Movement & Grid
    HISTORY_RESOLUTION = 2 # Pixels between history snapshots
    SEGMENT_SPACING = 15 # Snapshot distance between segments
    GRID_SIZE = 30 # Snake head/segment size
    BOARD_WIDTH = 900 # 30 * 30
    BOARD_HEIGHT = 900

    # Gameplay
    INITIAL_MOVE_SPEED = 150 # Pixels per second
    SPEED_INCREMENT = 5
    INVULNERABILITY_TIME = 0.5

    # Visuals
    SCREEN_WIDTH = 900
    SCREEN_HEIGHT = 900

    # Mega Food
    MEGA_FOOD_BITES_TO_FINISH = 3
    MEGA_FOOD_SPEED_MULTIPLIER = 0.5

    # UFO
    UFO_SPAWN_INTERVAL_RANGE = (30, 50)
    UFO_SPEED = 300
    UFO_SCORE_PENALTY = 5

    # Colors
    COLOR_GRASS = (34, 139, 34)
    COLOR_SNAKE = (50, 205, 50)
    COLOR_WALL = (139, 69, 19)
    COLOR_HUD_BG = (0, 0, 0, 128)
