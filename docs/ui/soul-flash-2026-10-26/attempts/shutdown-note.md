# Intermediate baseline diagnostic

After correcting screenshot timing, one baseline run passed6/6 and exited0 but emitted2 ObjectDB instances/1 resource at shutdown. The wrapper correctly rejected its clean-log assertion. The subsequent same-source verbose baseline exited clean, and the installed nine-case native run exited clean. No production code was edited for teardown. That intermediate raw log was overwritten by the verbose rerun; this note records the observed diagnostic without claiming a repair.
