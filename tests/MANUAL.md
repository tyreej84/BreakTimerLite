# Mixed-addon in-game check

Use a party or raid with a leader running Break Timer Lite 1.4.6, a DBM user,
and a BigWigs user. Also repeat with each boss addon enabled on the leader's
client alongside Break Timer Lite. Enable user/break timers in the boss addons.

1. Leader using Break Timer Lite: `/break 2 bio`. All three displays should count down to the same end.
2. After several seconds: `/break +1`. All displays should gain one minute.
3. `/break stop`. All displays should cancel.
4. Start and cancel with `/dbm break 2` and `/dbm break 0` on a DBM leader.
5. Start and cancel using BigWigs' break control on a BigWigs leader. If testing
   its `/break` command, ensure that command belongs to BigWigs; use `/bt` for
   Break Timer Lite. Repeat using a raid assistant.
6. Ordinary group members must not be able to control other players' timers.
7. Let a one-minute timer expire; inspect each display, warnings, and ready
   check behavior. Multiple enabled addons may play their own warning sounds.
8. Reload Break Timer Lite during a break and confirm local restoration.
   Cross-addon late-join recovery is not provided by this change.
9. Repeat in an instance group; inspect BugGrabber for restricted-message errors.

Automated check: `lua tests/boss-mod-sync.lua` from the addon directory.
These mocks exercise the actual integration and Core.lua state transitions;
they do not establish live WoW delivery or boss-addon rendering.

Protocol references reviewed for this change:
- https://github.com/BigWigsMods/BigWigs/blob/master/Plugins/Break.lua
- https://github.com/BigWigsMods/BigWigs/blob/master/Loader.lua
- https://github.com/DeadlyBossMods/DeadlyBossMods/blob/master/DBM-Core/modules/AddonComms.lua
- https://github.com/DeadlyBossMods/DeadlyBossMods/blob/master/DBM-Core/modules/UserTimers.lua
