#include amxmodx
#include colored_print

new const Messages[][] =
{
    "[ZC - Ads]^x01 We are looking for admins |^x03 wWw.Forum.Ro - section",
    "[ZC - Ads]^x03 Zombie Crown XP Mode v8.3 Legacy^x01 ||^x04 King Of The Zombies",
    "[ZC - Ads]^x01 Want vip? Type^x04 /vip | /buyvip^x01 for more details",
    "[ZC - Ads]^x01 The owner is^x03 Nume^x01 |^x03 Contact Discord:nume",
    "[ZC - Ads]^x01 Add the server to your favorites |^x04 IP Server"
}

public plugin_init()
{
    register_plugin("[ZC Chat Msg]", "0.1", "sNk_DarK")
    
    set_task(30.0, "DisplayMsg", _, _, _, "b")
}

public DisplayMsg() colored_print(0, GREEN, Messages[random_num(0, sizeof Messages-1)])