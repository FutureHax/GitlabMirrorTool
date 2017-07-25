# GitlabMirrorTool
Mirror and keep a fully working copy of all your repos automatically


This script needs a compain file named git_mirror_constants.txt with the following info

TOKEN = Gitlab token, acquired from your gitlab page
example - "k,jSDA243RW:FTG2"

HOST = Your gitlab host, and port is necessary
example - ssh://git@gitlab.plasticdonkies.org:2224

GITLAB_URL = Your full user gitlab url
example - https://gitlab.plasticdonkies.org/api/v3/projects --insecure


Once this file is created, run the "get_git.sh" script. This script is best added as a cron task.
