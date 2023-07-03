// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#define TF_RED 2
#define TF_BLU 3

static int RED_COUNT = 0;

public Plugin myinfo = {
    name        = "Machine Attacks Damage Path",
    author      = "Katsute",
    description = "Remove damage adjustments for Machine Attacks version 3",
    version     = "1.0",
    url         = "https://github.com/KatsuteTF/Machine-Attacks-Damage-Patch"
}

public void OnPluginStart(){
    for(int i = 1; i <= MaxClients; i++)
        HookDamage(i);
    RecountPlayers();
}

public void OnClientConnected(int client){
    HookDamage(client);
    RecountPlayers();
    RED_COUNT++;
}

public void OnClientDisconnect_Post(int client){
    RecountPlayers();
    RED_COUNT--;
}

public void HookDamage(const int client){
    if(IsClientInGame(client))
        SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
}

public void RecountPlayers(){
    int players = 0;
    for(int i = 1; i <= MaxClients; i++)
        if(IsClientInGame(i) && GetClientTeam(i) == TF_RED)
            players++;
    RED_COUNT = players;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3]){
    if(1 <= victim <= MaxClients && IsClientInGame(victim) && 1 <= attacker <= MaxClients && IsClientInGame(attacker)){
        int team = GetClientTeam(victim);

        switch(RED_COUNT){
            case 1, 2: {
                if(team == TF_RED)
                    damage *= 2.0;
                else if(team == TF_BLU)
                    damage *= 0.5;
            }
            case 3, 4, 5: {
                return Plugin_Continue;
            }
            case 6, 7, 8: {
                if(team == TF_RED)
                    damage *= 0.5;
                else if(team == TF_BLU)
                    damage *= 2.0;
            }
            case 9, 10: {
                if(team == TF_RED)
                    damage /= 3.0;
                else if(team == TF_BLU)
                    damage *= 4.0;
            }
        }
        return Plugin_Changed;
    }
    return Plugin_Continue;
}