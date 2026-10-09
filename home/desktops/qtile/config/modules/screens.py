from libqtile.config import Screen

# One entry per output. The bar comes back in a later step; outputs are
# matched in order, so this doesn't depend on connector names.
screens = [Screen() for _ in range(4)]
