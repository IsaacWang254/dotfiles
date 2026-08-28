# Wrapper around the `wt` script (~/.local/bin/wt).
#
# The script can't change this shell's directory, so it prints `cd <path>` on
# stdout and sends all its progress chatter to stderr. This function runs it,
# passes the output through, then performs that cd here — in the parent shell —
# so `wt SPOK-123` leaves you sitting in the new worktree.
function wt --description 'Create/enter an isolated git worktree under .trees/'
    set -l out (command wt $argv)
    set -l rc $status

    # Replay stdout for the human (stderr already streamed through live).
    test -n "$out" && printf '%s\n' $out

    test $rc -ne 0 && return $rc

    # Take the last `cd <path>` line the script emitted.
    set -l dest
    for line in $out
        if string match -q -- 'cd /*' $line
            set dest (string replace -- 'cd ' '' $line)
        end
    end

    if test -n "$dest" -a -d "$dest"
        cd $dest
    end
end
