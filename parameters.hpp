class Params
{
	class BaseLocation
	{
		title = "Base Location";
		values[] = {0, 1};
		texts[] = {"Custom", "Random"};
		default = 0;
	};
	class Combatants
	{
		title = "Combatants";
		values[] = {0, 1, 2};
		texts[] = {"WEST vs EAST", "WEST vs RESISTANCE", "EAST vs RESISTANCE"};
		default = 0;
	};
	class DefendersPlayable
	{
		title = "Defending side is playable";
		values[] = {0, 1};
		texts[] = {"Disabled", "Enabled"};
		default = 0;
	};
	class StartingCP
	{
		title = "Starting CP";
		values[] = {50, 250, 500, 1000, 2000, 5000, 10000, 1000000};
		default = 500;
	};
	class IncomeCalculation
	{
		title = "Income calculation";
		values[] = {0, 1};
		texts[] = {"Vanilla", "Advanced"};
		default = 1;
	};
	class MusicEnabled
	{
		title = "Music Enabled";
		values[] = {0, 1};
		default = 1;
	};
	class InitialProgress	// should we implement that or nah?
	{
		title = "Initial Progress";
		values[] = {0, 25, 50};
		default = 0;
	};
};