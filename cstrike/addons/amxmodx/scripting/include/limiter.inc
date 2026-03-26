#if defined _limiter_vault_included
	#endinput
#endif
#define _limiter_vault_included
#include <amxmodx>

stock const _limitervault_dir[] = "addons/amxmodx/data/save";
stock const _limitertemp_vault[] = "limiter_temp.txt";

stock limiter_get_data(const vaultname[], const itemid[], const key[], data[], len)
{
	new filename[128];
	_FormatLimiterVaultName(vaultname, filename, sizeof(filename) - 1);
	if( !file_exists(filename) )
	{
		return 0;
	}
	new vault = fopen(filename, "rt");
	new _data[512], _itemid[64], _key[64];
	while(!feof(vault))
	{
		fgets(vault, _data, sizeof(_data) - 1);
		parse(_data, _itemid, sizeof(_itemid) - 1, _key, sizeof(_key) - 1);
		if(equal(_itemid, itemid) && equal(_key, key))
		{
			new _len = strlen(_itemid) + 3 + strlen(_key) + 4;
			for( new i = copy(data, len, _data[_len]) - 1; i > 0; i-- )
			{
				if(data[i] == '"' ) break;
				if(data[i] == ' '
				&& data[i - 1] == '"')
				{
					data[i - 1] = '^0';
					break;
				}
			}
			fclose(vault);
			return 1;
		}
	}
	fclose(vault);
	copy(data, len, "");
	return 0;
}

stock limiter_set_data(const vaultname[], const itemid[], const key[], const data[])
{
	new file = fopen(_limitertemp_vault, "wt");
	new filename[128];
	_FormatLimiterVaultName(vaultname, filename, sizeof(filename) - 1);
	new vault = fopen(filename, "rt");
	new _data[512], _itemid[64], _key[64], _other[3];
	new bool:replaced = false;
	while(!feof(vault))
	{
		fgets(vault, _data, sizeof(_data) - 1);
		parse(_data, _itemid, sizeof(_itemid) - 1, _key, sizeof(_key) - 1, _other, sizeof(_other) - 1);
		if(equal(_itemid, itemid) && equal(_key, key) && !replaced )
		{
			fprintf(file, "^"%s^" ^"%s^" ^"%s^"^n", itemid, key, data);
			replaced = true;
		}else {
			fputs(file, _data);
		}
	}
	fclose(file);
	fclose(vault);
	if(!replaced)
	{
		file = fopen(filename, "a+");
		fprintf(file, "^"%s^" ^"%s^" ^"%s^"^n", itemid, key, data);
		fclose(file);
		delete_file(_limitertemp_vault);
	}else {
		delete_file(filename);
		while( !rename_file(_limitertemp_vault, filename, 1) ) { }
	}
}
 
stock _FormatLimiterVaultName(const vaultname[], filename[], len)
{
	static const invalid_chars[][] =
	{
		"/", "\", "*", ":", "?", "^"", "<", ">", "|"
	};
	static tempvault[128], i;
	copy(tempvault, sizeof(tempvault) - 1, vaultname);
	for( i = 0; i < sizeof(invalid_chars); i++ )
	{
		replace_all(tempvault, sizeof(tempvault) - 1, invalid_chars[i], "");
	}
	if( !dir_exists(_limitervault_dir) )
	{
		mkdir(_limitervault_dir);
	}
	formatex(filename, len, "%s/%s.txt", _limitervault_dir, tempvault);
}