// Author: Ivan Kazmenko (gassa@mail.ru)
module calculator;
import core.stdc.stdint;
import std.algorithm;
import std.format;
import std.json;
import std.range;
import std.stdio;

struct ritem
{
	uint64_t code;
	uint16_t stat1;
	uint16_t stat2;
	uint16_t stat3;
	uint16_t stat1_rand_range;
	uint16_t stat2_rand_range;
	uint16_t stat3_rand_range;
	uint8_t  stat2_reveal_rate;
	uint8_t  stat3_reveal_rate;
}

int get_variation_value (int amount, int rate)
{
	return -amount + (amount * 2) * rate / 100;
}

int calculate_item_score (ref ritem rule, uint32_t dna)
{
	uint32_t rate1 = dna & 0xFF; 
	uint32_t rate2 = (dna >> 8) & 0xFF; 
	uint32_t rate3 = (dna >> 16) & 0xFF;
	uint32_t reveal2 = (dna >> 24) & 0x2; 
	uint32_t reveal3 = (dna >> 24) & 0x4; 
	int stat1 = rule.stat1_rand_range +
	    get_variation_value (rule.stat1_rand_range, rate1);
	int stat2 = 0;
	if (reveal2 > 0)
	{
		stat2 = rule.stat2 +
		    get_variation_value (rule.stat2_rand_range, rate2);
	}
	int stat3 = 0;
	if (reveal3 > 0)
	{
		stat3 = rule.stat3 +
		    get_variation_value (rule.stat3_rand_range, rate3);
	}

	int stat1Max = rule.stat1_rand_range * 2;
	int stat2Max = rule.stat2 + rule.stat2_rand_range;
	int stat3Max = rule.stat3 + rule.stat3_rand_range;
	return (stat1 + stat2 + stat3) * 100 /
	    (stat1Max + stat2Max + stat3Max);
}

real [] calculate_chances (ref ritem rule)
{
	auto p = rule.stat2_reveal_rate * 0.01;
	auto q = rule.stat3_reveal_rate * 0.01;
	real [] probs = [
	    0.0, (1 - p) * (1 - q),
	    0.0, p * (1 - q),
	    0.0, (1 - p) * q,
	    0.0, p * q];
	probs[] *= 1.0 / (101 ^^ 3);

	auto res = new real [101];
	res[] = 0.0;

	void add (int stat1, int stat2, int stat3, int reveal2, int reveal3)
	{
	        uint32_t reveal1 = 1;
	        uint32_t reveal = (reveal3 << 2) | (reveal2 << 1) | reveal1;
		uint32_t dna = (reveal << 24) |
		    (stat3 << 16) | (stat2 << 8) | stat1;
		auto cur = calculate_item_score (rule, dna);
		res[cur] += probs[reveal];
	}

	foreach (stat1; 0..101)
	{
		foreach (stat2; 0..101)
		{
			foreach (stat3; 0..101)
			{
				foreach (reveal2; 0..2)
				{
					foreach (reveal3; 0..2)
					{
						add (stat1, stat2, stat3,
						    reveal2, reveal3);
					}
				}
			}
		}
	}

	return res;
}

void main ()
{
	ritem [] rules;
	real [] [] results;
	real [] answers;
	int [] los;
	int [] his;

	ritem rule;
	while (readf (" %s %s %s %s %s %s %s %s %s", &rule.code,
	    &rule.stat1, &rule.stat2, &rule.stat3, &rule.stat1_rand_range,
	    &rule.stat2_rand_range, &rule.stat3_rand_range,
	    &rule.stat2_reveal_rate, &rule.stat3_reveal_rate) > 0)
	{
		results ~= calculate_chances (rule);
		int lo, hi;
		readf (" %s %s", &lo, &hi);
		rules ~= rule;
		los ~= lo;
		his ~= hi;
		answers ~= sum (results[$ - 1][lo..hi + 1]);
	}

	auto n = answers.length;

	writefln ("%-18s%-(%15s%)", "Code:", n.iota.map !(k =>
	    format ("%d", rules[k].code)));
	writefln ("%-18s%-(%15s%)", "Goal %:", n.iota.map !(k =>
	    format ("%d%%-%d%%", los[k], his[k])));
	writefln ("%-18s%-(%15s%)", "Total probability:", n.iota.map !(k =>
	    format ("%.10f", answers[k])));
	writeln ("Complete tables:");
	foreach (i; 0..101)
	{
		writefln ("%18s%-(%15s%)", format ("%4d%%:", i),
		    n.iota.map !(k => format ("%.10f", results[k][i])));
	}
}
