#include <amxmodx>
#include <amxmisc>

#define MAX_GROUPS 8

new const g_groupNames[MAX_GROUPS][] = {
    "[BestZM]Founders",
    "[BestZM]Owners",
    "[BestZM]Co-Owner",
    "[BestZM]Elders",
    "[BestZM]Semi-Elders",
    "[BestZM]Moderators",
    "[BestZM]Administrators",
    "[BestZM]Helper"
};

new const g_groupFlags[MAX_GROUPS][] = {
    "abcdefghijklmnopqrstuvwxz",   // Founder
    "abcdefghijklnpqrstuvwx",        // Owner
    "bcdefghijklnpqrstu",            // Co-Owner
    "bcdefghijklnpqrs",              // Elder
    "bcdefghijklprs",                // Semi-Elder
    "bcdefghijklrs",                 // Moderator
    "bcefghijklrs",                  // Administrator
    "bceghijklrs"                    // Helper
};

new g_groupFlagsValue[MAX_GROUPS];

public plugin_init() {
    register_plugin("Amx Who", "1.0", "Amx Who");
    register_concmd("amx_who", "cmdWho", 0);

    for(new i = 0; i < MAX_GROUPS; i++) {
        g_groupFlagsValue[i] = read_flags(g_groupFlags[i]);
    }
}

public cmdWho(id) {
    new players[32], inum, player, name[32], i, a;
    get_players(players, inum);

    console_print(id, "Comunitatea BestZM");

    for(i = 0; i < MAX_GROUPS; i++) {
        console_print(id, "-----[%d]%s-----", i + 1, g_groupNames[i]);
        for(a = 0; a < inum; ++a) {
            player = players[a];
            get_user_name(player, name, 31);
            if(get_user_flags(player) == g_groupFlagsValue[i]) {
                console_print(id, "%s", name);
            }
        }
    }

    console_print(id, "Comunitatea BestZM");
    return PLUGIN_HANDLED;
}