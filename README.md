# ScreenTouches

A small library for displaying taps on the screen (including active elements) for testing and debugging iOS applications

### Use:

To start displaying taps:

```
ShowTouches.show = true
```
or if needed to customize for better visibility (color and size):

```
ShowTouches.show(with: .white, size: 32)
```

To stop:

```
ShowTouches.show = false
```
