module game.player;

import game.controller;
import game.entity.entity;

class Player
{
public:
	Entity entity; /// The entity that player is controlling
	Controller controller;
	string name; /// The name of the player
}