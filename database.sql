CREATE TABLE IF NOT EXISTS delta_system (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    fly_enabled BOOLEAN DEFAULT FALSE,
    auto_pickup_enabled BOOLEAN DEFAULT FALSE,
    UNIQUE KEY unique_player (player_id)
);

INSERT INTO delta_system (player_id, fly_enabled, auto_pickup_enabled) VALUES (1, FALSE, FALSE);