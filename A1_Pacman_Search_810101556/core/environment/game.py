from copy import deepcopy
from .ghost import Ghost
from .snack import Snack

class PacmanGame:
    def __init__(self, player: tuple[int, int], ghosts: list[Ghost], snacks: list[Snack], is_wall, move_direction=""):
        self.player = player
        self.ghosts = deepcopy(ghosts)
        self.snacks = deepcopy(snacks)
        self.is_wall = is_wall
        self.move_direction = move_direction
        self.height = len(is_wall)
        self.width = len(is_wall[0]) if self.height > 0 else 0

    def get_info(self):
        return (
            self.move_direction,
            [self.player] + [ghost.get_info() for ghost in self.ghosts] + [snack.get_info() for snack in self.snacks],
        )

    def determine_goal(self):
        remaining = [s.type for s in self.snacks if s.exists]
        if not remaining:
            return None
        return min(remaining)

    def in_bounds(self, x, y):
        return 0 <= x < self.height and 0 <= y < self.width

    def is_valid(self, x, y):
        return self.in_bounds(x, y) and not self.is_wall[x][y]

    def is_goal(self):
        return all(not s.exists for s in self.snacks)

    def get_map(self) -> str:
        height, width = self.height, self.width
        grid = [[" " for _ in range(width)] for _ in range(height)]
        for i in range(height):
            for j in range(width):
                if self.is_wall[i][j]:
                    grid[i][j] = "W"
        for s in self.snacks:
            if s.exists:
                grid[s.x][s.y] = s.type
        for g in self.ghosts:
            grid[g.x][g.y] = g.axis
        px, py = self.player
        grid[px][py] = "P"
        s = "╔" + "═" * width + "╗\n"
        for r in grid:
            s += "║" + "".join(r) + "║\n"
        s += "╚" + "═" * width + "╝\n"
        return s

    def _move_ghosts(self, ghosts):
        new = []
        for g in ghosts:
            ng = deepcopy(g)
            nx, ny = ng.get_next_position()
            cx, cy = ng.center
            disp = (nx - cx, ny - cy)
            if abs(disp[0]) > ng.radius or abs(disp[1]) > ng.radius:
                ng.direction *= -1
                nx, ny = ng.get_next_position()
            ng.set_state(nx, ny, ng.direction)
            new.append(ng)
        return new

    def _edible_type_now(self):
        return "A" if any(s.exists and s.type == "A" for s in self.snacks) else "B"

    def _consume_snack_if_any(self, snacks, player_pos):
        px, py = player_pos
        edible = self._edible_type_now()
        new_snacks = deepcopy(snacks)
        for s in new_snacks:
            if s.exists and (s.x, s.y) == (px, py) and s.type == edible:
                s.exists = False
        return new_snacks

    def get_next_states(self):
        moves = {"U": (-1, 0), "L": (0, -1), "D": (1, 0), "R": (0, 1)}
        next_states = []
        px, py = self.player
        for label, (dx, dy) in moves.items():
            npx, npy = px + dx, py + dy
            if not self.is_valid(npx, npy):
                continue
            nxt = PacmanGame(
                player=(npx, npy),
                ghosts=deepcopy(self.ghosts),
                snacks=deepcopy(self.snacks),
                is_wall=self.is_wall,
                move_direction=label,
            )
            prev_ghosts = [(g.x, g.y) for g in nxt.ghosts]
            nxt.ghosts = self._move_ghosts(nxt.ghosts)
            if any((g.x, g.y) == (npx, npy) for g in nxt.ghosts):
                continue
            if any(((g.x, g.y) == (px, py) and prev_ghosts[i] == (npx, npy)) for i, g in enumerate(nxt.ghosts)):
                continue
            nxt.snacks = self._consume_snack_if_any(nxt.snacks, (npx, npy))
            next_states.append((label, nxt))
        return next_states

    def get_state(self):
        player = self.player
        ghosts = tuple((g.x, g.y, g.axis, g.direction, g.radius, g.center) for g in self.ghosts)
        snacks = tuple((s.x, s.y, s.type, s.exists) for s in self.snacks)
        return (player, ghosts, snacks)
