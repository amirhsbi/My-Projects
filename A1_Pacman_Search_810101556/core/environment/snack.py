class Snack:
    def __init__(self, x, y, typeOfSnack, exists = True):
        self.x = x
        self.y = y
        self.type = typeOfSnack # either 'A' or 'B'
        self.exists = exists

    def get_info(self):
        return self.x,self.y, self.type, self.exists
    
    """
        Updates existence of snack in case of a collision with Pacman
    """
    def update_state(self, snacks):        
        must_eaten_before = [s.get_state() for s in snacks if s.type < self.type]
        self.exists = sum(must_eaten_before) > 0