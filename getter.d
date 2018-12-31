// Author: Ivan Kazmenko (gassa@mail.ru)
module getter;
import std.format, std.json, std.net.curl, std.range, std.stdio, std.string;

immutable string apiEndpoint = "https://eos.greymass.com";
immutable string apiQuery = apiEndpoint ~ "/v1/chain/get_table_rows";
immutable string apiData = format ("{%-(%s,%)}", [
    `"scope":"eosknightsio"`,
    `"code":"eosknightsio"`,
    `"table":"%s"`,
    `"limit":999999999`,
    `"json":"true"`,
    ]);

void main (string [] args)
{
	foreach (name; args[1..$])
	{
		writeln (name);
		auto cur = post (apiQuery, format (apiData, name)).parseJSON;
		cur = cur["rows"];
		File (name ~ ".json", "w").writeln (cur);
	}
}
