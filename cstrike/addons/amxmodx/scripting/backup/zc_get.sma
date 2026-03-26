#include amxmodx
#include zombiecrown
#include colored_print


#define GetPacks random_num(25, 70)
#define GetXP random_num(0, 4)
#define GetLevel random_num(0, 1)
#define GetPoints random_num(0, 4)
#define GetCoins random_num(0, 4)

new const GetItems[][] =
{
    "Get Random \yPacks \r(25, 70)",
    "Get Random \yXP \r(0, 4)",
    "Get Random \yLevel \r(0, 1)",
    "Get Random \yPoints \r(0, 4)",
    "Get Random \yCoins \r(0, 4)"
}

public plugin_init()
{


    register_plugin("[ZC Free Benefits]", "0.1", "sNk_DarK")

    register_clcmd("say /get", "FreeBenefits")
}

public plugin_natives()
    register_native("ShowGetMenu", "ShowGetMenu", 1)

public ShowGetMenu(id)
{
    FreeBenefits(id)
    return 1
}

public FreeBenefits(id)
{

    new menu = menu_create("\y[ZC] \rFree Rewards \d(once per map)")

    new buffer[120]

    for (new i = 0; i < sizeof GetItems; i++)
    {
        format(buffer, 120, "%s", GetItems[i])
        menu_additem(menu, buffer)
    }

    ZC_MenuDisplay(id, menu)
}

public GiveReward(id, whatiselected)
{
    switch (whatiselected)
    {
        case 0: // Packs
        {
            new zp_packs = GetPacks
            colored_print(id, GREEN, "[ZC]^x01 You have received^x03 %d Packs!", zp_packs)
            zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + zp_packs)           
        }

        case 1: // XP
        {
            new zp_xp = GetXP
            colored_print(id, GREEN, "[ZC]^x01 You have received^x03 %d XP!", zp_xp)
            zp_set_user_xp(id, zp_get_user_xp(id) + zp_xp)
        }

        case 2: // Level
        {
            new zp_level = GetLevel
            colored_print(id, GREEN, "[ZC]^x01 You have received^x03 %d Level(s)!", zp_level)
            zp_set_user_level(id, zp_get_user_level(id) + zp_level)
        }

        case 3: // Points
        {
            new zp_points = GetPoints
            colored_print(id, GREEN, "[ZC]^x01 You have received^x03 %d Points!", zp_points)
            zp_set_user_points(id, zp_get_user_points(id) + zp_points)
        }

        case 4: // Coins
        {
            new zp_coins = GetCoins
            colored_print(id, GREEN, "[ZC]^x01 You have received^x03 %d Coins!", zp_coins)
            zp_set_user_coins(id, zp_get_user_coins(id) + zp_coins)
        }
    }
}

ZC_MenuDisplay(id, menu)
{
    if (!is_user_connected(id)) return

    menu_display(id, menu)
}
