{ pkgs }:
{
  manager = {
    ratio = [ 1 4 6 ];
    sort_by = "alphabetical";
    sort_sensitive = false;
    sort_reverse = false;
    sort_dir_first = true;
    sort_translit = false;
    linemode = "none";
    show_hidden = false;
    show_symlink = true;
    scrolloff = 5;
    mouse_events = [ "click" "scroll" ];
  };
}
