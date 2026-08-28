# Adaptive Dracula (dark) / Alucard (light) theme for bobthefish + fish colors.
# Follows macOS appearance when dracula_theme_mode is auto (default).

if not set -q dracula_theme_mode
    set -U dracula_theme_mode auto
end

function __dracula_detect_appearance -d 'Return dark or light from macOS system appearance'
    if test (uname) = Darwin
        defaults read -g AppleInterfaceStyle 2>/dev/null | string match -q Dark
        and echo dark
        or echo light
    else if set -q COLORFGBG
        string match -qr '.*;1[0-5]$' -- $COLORFGBG
        and echo light
        or echo dark
    else
        echo dark
    end
end

function __dracula_resolve_appearance -d 'Resolve effective appearance from mode + system'
    switch $dracula_theme_mode
        case dark light
            echo $dracula_theme_mode
        case '*'
            __dracula_detect_appearance
    end
end

function __dracula_apply_syntax -a appearance -d 'Apply fish syntax highlighting for appearance'
    switch $appearance
        case dark
            set -U fish_color_normal normal
            set -U fish_color_command F8F8F2
            set -U fish_color_quote F1FA8C
            set -U fish_color_redirection 8BE9FD
            set -U fish_color_end 50FA7B
            set -U fish_color_error FF5555
            set -U fish_color_param 5FFFFF
            set -U fish_color_comment 6272A4
            set -U fish_color_match --background=brblue
            set -U fish_color_selection white --bold --background=brblack
            set -U fish_color_search_match bryellow --background=brblack
            set -U fish_color_history_current --bold
            set -U fish_color_operator 00a6b2
            set -U fish_color_escape 00a6b2
            set -U fish_color_cwd green
            set -U fish_color_cwd_root red
            set -U fish_color_valid_path --underline
            set -U fish_color_autosuggestion BD93F9
            set -U fish_color_user brgreen
            set -U fish_color_host normal
            set -U fish_color_cancel -r
            set -U fish_pager_color_completion normal
            set -U fish_pager_color_description B3A06D yellow
            set -U fish_pager_color_prefix white --bold --underline
            set -U fish_pager_color_progress brwhite --background=cyan
        case light
            set -U fish_color_normal normal
            set -U fish_color_command 1F1F1F
            set -U fish_color_quote 846E15
            set -U fish_color_redirection 036A96
            set -U fish_color_end 14710A
            set -U fish_color_error CB3A2A
            set -U fish_color_param 036A96
            set -U fish_color_comment 6C664B
            set -U fish_color_match --background=CFCFDE
            set -U fish_color_selection 1F1F1F --bold --background=CFCFDE
            set -U fish_color_search_match 846E15 --background=EFEDDC
            set -U fish_color_history_current --bold
            set -U fish_color_operator 036A96
            set -U fish_color_escape 036A96
            set -U fish_color_cwd 14710A
            set -U fish_color_cwd_root CB3A2A
            set -U fish_color_valid_path --underline
            set -U fish_color_autosuggestion 644AC9
            set -U fish_color_user 14710A
            set -U fish_color_host normal
            set -U fish_color_cancel -r
            set -U fish_pager_color_completion normal
            set -U fish_pager_color_description 6C664B 846E15
            set -U fish_pager_color_prefix 1F1F1F --bold --underline
            set -U fish_pager_color_progress 1F1F1F --background=036A96
    end
end

function bobthefish_colors -S -d 'Alucard bobthefish override (light mode only)'
    test "$__dracula_appearance" = light
    or return

    set -l bg           fffbeb
    set -l selection    cfcfde
    set -l fg           1f1f1f
    set -l comment      6c664b
    set -l cyan         036a96
    set -l green        14710a
    set -l orange       a34d14
    set -l pink         a3144d
    set -l purple       644ac9
    set -l red          cb3a2a
    set -l yellow       846e15

    set -x color_initial_segment_exit     $fg $red --bold
    set -x color_initial_segment_private  $fg $selection
    set -x color_initial_segment_su       $fg $purple --bold
    set -x color_initial_segment_jobs     $fg $comment --bold

    set -x color_path                     $selection $fg
    set -x color_path_basename            $selection $fg --bold
    set -x color_path_nowrite             $selection $red
    set -x color_path_nowrite_basename    $selection $red --bold

    set -x color_repo                     $green $bg
    set -x color_repo_work_tree           $selection $fg --bold
    set -x color_repo_dirty               $red $bg
    set -x color_repo_staged              $yellow $bg

    set -x color_vi_mode_default          $bg $yellow --bold
    set -x color_vi_mode_insert           $green $bg --bold
    set -x color_vi_mode_visual           $orange $bg --bold

    set -x color_vagrant                  $pink $bg --bold
    set -x color_k8s                      $purple $bg --bold
    set -x color_aws_vault                $comment $yellow --bold
    set -x color_aws_vault_expired        $comment $red --bold
    set -x color_username                 $selection $cyan --bold
    set -x color_hostname                 $selection $cyan
    set -x color_screen                   $green $bg --bold
    set -x color_rvm                      $red $bg --bold
    set -x color_node                     $green $bg --bold
    set -x color_virtualfish              $comment $bg --bold
    set -x color_virtualgo                $cyan $bg --bold
    set -x color_desk                     $comment $bg --bold
    set -x color_nix                      $cyan $bg --bold
end

function dracula_theme -d 'Manage adaptive Dracula/Alucard theme (auto|dark|light|status)'
    set -l cmd $argv[1]

    switch $cmd
        case auto dark light
            set -U dracula_theme_mode $cmd
            set -e __dracula_appearance
            dracula_theme sync
            echo "dracula theme: $cmd"
        case status
            set -l effective (__dracula_resolve_appearance)
            echo "mode: $dracula_theme_mode"
            echo "effective: $effective"
            echo "bobthefish: "(test "$effective" = dark; and echo dracula; or echo alucard)
        case sync ''
            set -l appearance (__dracula_resolve_appearance)
            if set -q __dracula_appearance; and test "$appearance" = "$__dracula_appearance"
                return 0
            end

            set -g __dracula_appearance $appearance
            if test "$appearance" = dark
                set -g theme_color_scheme dracula
            else
                set -g theme_color_scheme alucard
            end
            __dracula_apply_syntax $appearance
            status is-interactive; and commandline -f repaint
        case '*'
            echo "usage: dracula_theme [auto|dark|light|status|sync]"
            return 1
    end
end

function __dracula_theme_sync --on-event fish_prompt
    dracula_theme sync
end

dracula_theme sync
