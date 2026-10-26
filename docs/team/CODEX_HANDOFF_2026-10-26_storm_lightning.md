# ACC-10: softer lightning under Reduce motion

October 26, 2026. **A1 of CODEX_TASKS_2026-10-26.md complete/installed.**

Storm now honors both title-forwarded and shared saved Reduce motion. Each reduced strike initializes one pulse at0.4 and uses the existing0.35s fade; the wait pattern1.4/1.9/1.2s is uncompressed. Normal double pulses at0.85, wind, one thunder per strike/SFX bus and all later story/input/destination behavior are preserved.

Native33/33 clean across normal, forwarded-only and saved-only settings. Reduced cases each show3 monotonic soft pulses, native shader peak about0.362 after the first tween step, sampled nonzero fade about0.333s, full later gaps1.93/1.23s. Normal retains6 pulses at0.85. Tests verify frozen/grey rain, landing, existing soul destination and private save hashes. Baseline6/6 clean records the old6 bright reduced pulses. Official storm_open/opening_flow both PASS, exit0; known raw exit warnings retained. [Preview, originals, commands, frame samples and diff](../ui/storm-lightning-2026-10-26/README.md).

Only storm_open.gd edited; originals and protected baseline archived. Claude/Grok concurrent work preserved and listed in receipt. Native captures inspected in Compatibility; private profiles/saves only. First screenshot diagnostic captured state one frame before the shader; corrected to shader-peak capture, initial attempt retained. No art/generation/paid call/rules/Route1/message/commit.

Final native33 and official2 regressions rerun after Claude's shared preference copy/backup-reader and HEAD removal edits. All pass; tested shared snapshots retained, current pref helper bodies match. Earlier passes archived separately.

Source issues for Claude: no new lightning-path issue. A2 / ACC-14 soul flash and A3 full white-outs remain pending. Pass8 plan L04 proposes enabling C6, but the dedicated October26 queue explicitly keeps it off until Preston picks wording; flag unchanged OFF. Claude's C1 shared recovery edits preserved; broader validation remains in his pass8 lane. No cross-chat message sent.

Next: A2 / ACC-14, cap the reduced soul flash at0.4. Non-creature town/exterior art stays on HOLD until the new slot registry/designs exist.
