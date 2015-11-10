module game.defines;

import engine.math;

enum path_graphics = "data/graphics/";
enum path_levels = "data/maps/";
enum path_objects = "data/objects/";

enum Gravity_Constant = 9.81;
enum meters_per_pixel = 1/8f;
enum Gravity_Acceleration = Vector2f( 0, Gravity_Constant/meters_per_pixel );