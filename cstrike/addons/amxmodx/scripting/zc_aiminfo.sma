#include amxmodx
#include zombiecrown

new g_msg

public plugin_init()
{
        register_event("StatusValue", "ShowStatus", "be", "1=2", "2!0")
        register_event("StatusValue", "HideStatus", "be", "1=1", "2=0")

        g_msg = CreateHudSyncObj()
}

public ShowStatus(id)
{
	if (is_user_connected(id) && !is_user_bot(id))
	{
		new health[14], armor[14], victim
		
		victim = read_data(2)

		if (zp_get_user_zombie(victim) && !zp_get_user_zombie(id))
		{
			AddCommas(get_user_health(victim), health, 13)
		
			set_hudmessage(247, 195, 0, -1.0, 0.60, 0, 6.0, 1.1, 0.0, 0.0, -1)
			ShowSyncHudMsg(id, g_msg, "%s^nHealth: %s", get_name(victim), health)
		}
                else if (zp_get_user_zombie(id) && !zp_get_user_zombie(victim))
                {
                        AddCommas(get_user_health(victim), health, 13)
                        AddCommas(get_user_armor(victim), armor, 13)
		
			set_hudmessage(247, 195, 0, -1.0, 0.60, 0, 6.0, 1.1, 0.0, 0.0, -1)
			ShowSyncHudMsg(id, g_msg, "%s^nHealth: %s | Armor: %s", get_name(victim), health, armor)
                }
	}
}

public HideStatus(id) ClearSyncHud(id, g_msg)

get_name(id)
{
        new name[32]; get_user_name(id, name, 32)
        return name
}

AddCommas(Num, Output[], Len)
{
   static Tmp[16], OutputPos = 0, NumPos = 0, NumLen = 0;
   OutputPos = NumPos = 0;
   if (Num < 0)
   {
      Output[OutputPos++] = '-';
      Num = abs(Num);
   }
   NumLen = num_to_str(Num, Tmp, charsmax(Tmp));
   if (NumLen <= 3)
   {
      OutputPos += copy(Output[OutputPos], Len, Tmp);
   }
   else
   {
      while (NumPos < NumLen && OutputPos < Len)
      {
         Output[OutputPos++] = Tmp[NumPos++];
         if (NumLen - NumPos && !((NumLen - NumPos) % 3))
		 {
            Output[OutputPos++] = '.';
		 }
      }
      Output[OutputPos] = '^0';
   }
}