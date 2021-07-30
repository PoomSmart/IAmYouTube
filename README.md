# IAmYouTube

Potentially useful for sideloaded YouTube where certain operations read bundle ID of the app rather than assuming it's just the official YouTube.

Bundle identifier checks serve multiple purposes. Some apps (YouTube included) does it for functionalities (for example, check if itself is a developer build). Some apps does it for integrity (so that it won't run in the "contaminated" self). Some apps does it for analytics.
