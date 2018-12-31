// Author: Ivan Kazmenko (gassa@mail.ru)
module list;
import std.algorithm;
import std.format;
import std.json;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

void main (string [] args)
{
	auto cquest = File ("cquest.json").readln.parseJSON;
	auto ritem = File ("ritem.json").readln.parseJSON;

	auto lastQuest = cquest.array[$ - 1]["subquests"];
	foreach (q; lastQuest.array)
	{
		auto code = q["detail"]["code"].integer;
		auto rule = ritem.array.find
		    !(x => x["code"].integer == code).front;
		writefln ("%s %s %s %s %s %s %s %s %s", rule["code"],
		    rule["stat1"], rule["stat2"], rule["stat3"],
		    rule["stat1_rand_range"],
		    rule["stat2_rand_range"], rule["stat3_rand_range"],
		    rule["stat2_reveal_rate"], rule["stat3_reveal_rate"]);
		writefln ("%s %s", q["detail"]["score_from"],
		    q["detail"]["score_to"]);
	}
}
