#include amxmodx
#include fakemeta
 
 
 
#define NUMAR_DE_BOTI 2
 
new g_Query[256];
 
public plugin_init()
{
        set_task( 15.0, "TaskManageBots", .flags="b" );
}
 
new g_Bot[33], g_BotsCount;
 
public TaskManageBots(){
        static PlayersNum; PlayersNum  = get_playersnum( 1 );
        if( PlayersNum < get_maxplayers() - 1 && g_BotsCount < NUMAR_DE_BOTI ) {
                CreateBot();
        } else if( PlayersNum > get_maxplayers() - 1 && g_BotsCount ) {
                RemoveBot();
        }}
 
new const g_Names[][]=
{
        "Zombie Crown XP Mode v8.3",
        "VIP = 12 Euro",
        "Justin Bieber",
        "Selena Gomez"
};

public client_putinserver(i) g_Bot[ i ] = false;
 
public client_disconnect(i)
{
        if( g_Bot[ i ] ) {
                g_Bot[ i ] = 0, g_BotsCount -- ;
        }
}
 
RemoveBot(){
        static i;
        for( i = 1; i <= get_maxplayers(); i++ ) {
                if( g_Bot[ i ] ) {
                        server_cmd( "kick #%d", get_user_userid( i ) );break;
                }}}
 
CreateBot(){
        static Bot;
        formatex( g_Query, 255, !random_num(0,1)?"%s (%c%c)":"%s - %c%c",g_Names[random_num(0,sizeof(g_Names)-1)],random_num('A','Z'),random_num('A','Z') );Bot = engfunc( EngFunc_CreateFakeClient, g_Query );
        if( Bot > 0 &&pev_valid(Bot)) {
                dllfunc(MetaFunc_CallGameEntity,"player",Bot);
                set_pev(Bot,pev_flags,FL_FAKECLIENT);
                set_pev(Bot, pev_model, "");
                set_pev(Bot, pev_viewmodel2, "");
                set_pev(Bot, pev_modelindex, 0);
                set_pev(Bot, pev_renderfx, kRenderFxNone);
                set_pev(Bot, pev_rendermode, kRenderTransAlpha);
                set_pev(Bot, pev_renderamt, 0.0);
                set_pdata_int(Bot,114,0);
                message_begin(MSG_ALL,get_user_msgid("TeamInfo"));
                write_byte(Bot);
                write_string("UNASSIGNED");
                message_end();
                g_Bot[Bot]=1;
                g_BotsCount++;
        }
}