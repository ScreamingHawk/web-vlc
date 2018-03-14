# web-vlc

A website for selecting shows to watch on VLC locally

## Configuration

There are a couple of points of configuration required to use this app correctly.

### VLC configuration

VLC must be configured to expose it's web API.

To do this, check the following setting.

1. `Tools > Preferences`
2. At the bottom for `Show settings`, check `All`
3. `Interface > Main interfaces`
4. Check the `web` checkbox
5. `Interface > Main interfaces > Lua`
6. Enter a password into `Lua HTTP > Password`. (This password goes into the app configuration below)
7. `Save`
8. Close and re-open VLC
9. Accept the network prompt if shown
10. Navigate to `http://localhost:8080` to see if it worked

### App configuration

Edit `server/config.yaml` with your defaults.

Ensure the `vlc.command` works in your console.

Copy the paths to your videos into `files.locations`.

### Video file structure

Files must be organised like so:

```
Show Name
	> Season x
		> video_episode_xx.ext
```

Season folder may be omitted.
There is some intelligence to detect episode number, otherwise the video name can be anything.


## Usage

Install dependencies.

```
npm i
```

Edit `server/config.yaml` with your defaults.

Build everything and run in a single command, because you are lazy.

```
npm run complete
```

Navigate to the application at `http://localhost:3000`.
Note your path may be different if you changed the config.

## Development

Watch for CoffeeScript changes.

```
npm run coffee-watch
```

Watch for Webpack changes.

```
npm run webpack-watch
```

Run server watching for changes.

```
npm run start-watch
```
