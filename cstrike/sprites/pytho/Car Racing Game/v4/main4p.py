import pygame
import time
import math
from utils import scale_image, blit_rotate_center, blit_text_center

pygame.font.init()  # loading the font

GRASS = scale_image(pygame.image.load("assets/background.asset"), 3)  # Importing the Background
TRACK = scale_image(pygame.image.load("assets/track.asset"), 1.1)  # Importing the Roads

TRACK_BORDER = scale_image(pygame.image.load("assets/track-border.asset"), 1.1)  # Importing the tracks for collisions
TRACK_BORDER_MASK = pygame.mask.from_surface(TRACK_BORDER)  # Setting the surface

FINISH = pygame.image.load("assets/finish.asset")  # Loading the end part
FINISH_MASK = pygame.mask.from_surface(FINISH)  # Setting the position of the finish line
FINISH_POSITION = (160, 250)  # Setting cordinates for finish

RED_CAR = player1 = scale_image(pygame.image.load("assets/red-car.asset"), 0.18)  # Importing the player 1 red car
black_CAR = player2 = scale_image(pygame.image.load("assets/black-car.asset"), 0.18)  # Importing the player 2 black car
GREY_CAR = player3 = scale_image(pygame.image.load("assets/grey-car.asset"), 0.18)  # Importing the player 3 grey car
yellow_CAR = player4 = scale_image(pygame.image.load("assets/yellow-car.asset"), 0.18)  # Importing the player 4 yellow car

WIDTH, HEIGHT = TRACK.get_width(), TRACK.get_height()  # Loading the Images
WIN = pygame.display.set_mode((WIDTH, HEIGHT))  # Loading the Win Screen
pygame.display.set_caption("4p racing game")  # Setting the App name

MAIN_FONT = pygame.font.SysFont("modern", 40)  # Setting the Font Size

FPS = 100000  # Frame Rate Per Second (FPS)


class GameInfo:
    rounds = 10  # Total rounds before winning

    def __init__(self, round=1):
        self.round = round
        self.started = False
        self.round_start_time = 0

    def next_round(self):
        self.round += 1
        self.started = False

    def reset(self):
        self.round = 1
        self.started = False
        self.round_start_time = 0

    def game_finished(self):
        return self.round > self.rounds

    def start_round(self):
        self.started = True
        self.round_start_time = time.time()

    def get_round_time(self):
        if not self.started:
            return 0
        return round(time.time() - self.round_start_time)


class AbstractCar:
    def __init__(self, max_vel, rotation_vel):
        self.img = self.IMG
        self.max_vel = max_vel
        self.vel = 0
        self.rotation_vel = rotation_vel
        self.angle = 0
        self.x, self.y = self.START_POS
        self.acceleration = 0.3

    def rotate(self, left=False, right=False):
        if left:
            self.angle += self.rotation_vel
        elif right:
            self.angle -= self.rotation_vel

    def draw(self, win):
        blit_rotate_center(win, self.img, (self.x, self.y), self.angle)

    def move_forward(self):
        self.vel = min(self.vel + self.acceleration, self.max_vel)
        self.move()

    def move_backward(self):
        self.vel = max(self.vel - self.acceleration, -self.max_vel * 2)
        self.move()

    def move(self):
        radians = math.radians(self.angle)
        vertical = math.cos(radians) * self.vel
        horizontal = math.sin(radians) * self.vel

        self.y -= vertical
        self.x -= horizontal

    def collide(self, mask, x=0, y=0):
        car_mask = pygame.mask.from_surface(self.img)
        offset = (int(self.x - x), int(self.y - y))
        poi = mask.overlap(car_mask, offset)
        return poi

    def reset(self):
        self.x, self.y = self.START_POS
        self.angle = 0
        self.vel = 0


class PlayerCar1(AbstractCar):  # Define the Player Car 1
    IMG = yellow_CAR  # Car Image or Car look
    START_POS = (180, 190)  # Car Spawn Position in px

    def reduce_speed(self):  # Allowing car to slow instead of intimidatingly stopping
        self.vel = max(self.vel - self.acceleration / 2, 0)  # Formula for the velocity
        self.move()  # Allowing the car to move instead of remaining at negative speed

    def bounce(self):  # Making the Car Bounce after touching the road
        self.vel = -self.vel  # Formula for bounce
        self.move()  # Allowing the car to move again instead of bouncing then stopping


class PlayerCar2(AbstractCar):  # Define the Player Car 2
    IMG = black_CAR  # Car Image or Car look
    START_POS = (180, 130)  # Car Spawn Position in px

    def reduce_speed(self):  # Allowing car to slow instead of intimidatingly stopping
        self.vel = max(self.vel - self.acceleration / 2, 0)  # Formula for the velocity
        self.move()  # Allowing the car to move instead of remaining at negative speed

    def bounce(self):  # Making the Car Bounce after touching the road
        self.vel = -self.vel  # Formula for bounce
        self.move()  # Allowing the car to move again instead of bouncing then stopping


class PlayerCar3(AbstractCar):  # Define the Player Car 3
    IMG = GREY_CAR  # Car Image or Car look
    START_POS = (210, 130)  # Car Spawn Position in px

    def reduce_speed(self):  # Allowing car to slow instead of intimidatingly stopping
        self.vel = max(self.vel - self.acceleration / 2, 0)  # Formula for the velocity
        self.move()  # Allowing the car to move instead of remaining at negative speed

    def bounce(self):  # Making the Car Bounce after touching the road
        self.vel = -self.vel  # Formula for bounce
        self.move()  # Allowing the car to move again instead of bouncing then stopping


class PlayerCar4(AbstractCar):  # Define the Player Car 4
    IMG = RED_CAR  # Car Image or Car look
    START_POS = (210, 190)  # Car Spawn Position in px

    def reduce_speed(self):  # Allowing car to slow instead of intimidatingly stopping
        self.vel = max(self.vel - self.acceleration / 2, 0)  # Formula for the velocity
        self.move()  # Allowing the car to move instead of remaining at negative speed

    def bounce(self):  # Making the Car Bounce after touching the road
        self.vel = -self.vel  # Formula for bounce
        self.move()  # Allowing the car to move again instead of bouncing then stopping


def draw(win, images, player_car1, player_car2, player_car3, player_car4, game_info):
    for img, pos in images:
        win.blit(img, pos)

    owner_test = MAIN_FONT.render(  # Rendering the Owner Name
        f"MADE BY n00bi2763", 1, (255, 255, 255))  # Colour of the text
    win.blit(owner_test, (3, HEIGHT - owner_test.get_height() - 10))  # Text Position

    round_text = MAIN_FONT.render(  # Rendering the Round Number
        f"Round: {game_info.round}", 1, (255, 255, 255))  # Colour of the text
    win.blit(round_text, (3, HEIGHT - round_text.get_height() - 80))  # Text Position

    time_text = MAIN_FONT.render(  # Rendering the time
        f"Time: {game_info.get_round_time()}s", 1, (255, 255, 255))  # Colour of the text
    win.blit(time_text, (3, HEIGHT - time_text.get_height() - 45))  # Text Position

    player_car1.draw(win)  # Showing that player won
    player_car2.draw(win)  # Showing that player won
    player_car3.draw(win)  # Showing that player won
    player_car4.draw(win)  # Showing that player won
    pygame.display.update()  # Removing that player won


def move_player(player_car1):  # Setting Controls for Player 1
    keys = pygame.key.get_pressed()
    moved = False  # For making the velocity effect car

    if keys[pygame.K_a]:  # Condition for moving Left
        player_car1.rotate(left=True)  # Rotating the car
    if keys[pygame.K_d]:  # Condition for moving Right
        player_car1.rotate(right=True)  # Rotating the car
    if keys[pygame.K_w]:  # Condition for moving Up
        moved = True  # For making the velocity effect car
        player_car1.move_forward()  # Moving the Car
    if keys[pygame.K_s]:  # Condition for moving Down
        moved = True  # For making the velocity effect car
        player_car1.move_backward()  # Moving the Car

    if not moved:  # Condition for deceleration
        player_car1.reduce_speed()  # Decelerating

def move_player2(player_car2):  # Setting Controls for Player 1
    keys2 = pygame.key.get_pressed()
    moved = False  # For making the velocity effect car

    if keys2[pygame.K_LEFT]:  # Condition for moving Left
        player_car2.rotate(left=True)  # Rotating the car
    if keys2[pygame.K_RIGHT]:  # Condition for moving right
        player_car2.rotate(right=True)  # Rotating the car
    if keys2[pygame.K_UP]:  # Condition for moving Up
        moved = True  # For making the velocity effect car
        player_car2.move_forward()  # Moving the Car
    if keys2[pygame.K_DOWN]:  # Condition for moving Back
        moved = True  # For making the velocity effect car
        player_car2.move_backward()  # Moving the Car

    if not moved:  # Condition for deceleration
        player_car2.reduce_speed()  # Decelerating


def move_player3(player_car3):  # Setting Controls for Player 1
    keys3 = pygame.key.get_pressed()
    moved = False  # For making the velocity effect car

    if keys3[pygame.K_4]:  # Condition for moving Left
        player_car3.rotate(left=True)  # Rotating the car
    if keys3[pygame.K_6]:  # Condition for moving Right
        player_car3.rotate(right=True)  # Rotating the car
    if keys3[pygame.K_8]:  # Condition for moving Up
        moved = True  # For making the velocity effect car
        player_car3.move_forward()  # Moving the Car
    if keys3[pygame.K_5]:  # Condition for moving Down
        moved = True  # For making the velocity effect car
        player_car3.move_backward()  # Moving the Car

    if not moved:  # Condition for deceleration
        player_car3.reduce_speed()  # Decelerating


def move_player4(player_car4):  # Setting Controls for Player 1
    keys4 = pygame.key.get_pressed()
    moved = False  # For making the velocity effect car

    if keys4[pygame.K_h]:  # Condition for moving Left
        player_car4.rotate(left=True)  # Rotating the car
    if keys4[pygame.K_k]:  # Condition for moving Right
        player_car4.rotate(right=True)  # Rotating the car
    if keys4[pygame.K_u]:  # Condition for moving Up
        moved = True  # For making the velocity effect car
        player_car4.move_forward()  # Moving the Car
    if keys4[pygame.K_j]:  # Condition for moving Down
        moved = True  # For making the velocity effect car
        player_car4.move_backward()  # Moving the Car

    if not moved:  # Condition for deceleration
        player_car4.reduce_speed()  # Decelerating


def handle_collision(player_car1, player_car2, player_car3, player_car4, game_info):  # Script for the car bouncing after hitting the bordor
    if player_car1.collide(TRACK_BORDER_MASK) != None:
        player_car1.bounce()  # Bounce Car 1 on collision
    if player_car2.collide(TRACK_BORDER_MASK) != None:
        player_car2.bounce()  # Bounce Car 2 on collision
    if player_car3.collide(TRACK_BORDER_MASK) != None:
        player_car3.bounce()  # Bounce Car 3 on collision
    if player_car4.collide(TRACK_BORDER_MASK) != None:
        player_car4.bounce()  # Bounce Car 4 on collision

    player_finish_poi_collide = player_car1.collide(  # Script for Collision with the Winning Area
        FINISH_MASK, *FINISH_POSITION)
    if player_finish_poi_collide != None:  # Not allowing the player to go wrong way
        if player_finish_poi_collide[1] == 0:
            player_car1.bounce()  # Bouncing back from the Wrong way
        else:
            game_info.next_round()
            print("player1 win round")
            player_car1.reset()  # Reset Player 1 Position
            player_car2.reset()  # Reset Player 2 Position
            player_car3.reset()  # Reset Player 3 Position
            player_car4.reset()  # Reset Player 4 Position

    player_finish_poi_collide = player_car2.collide(
        FINISH_MASK, *FINISH_POSITION)
    if player_finish_poi_collide != None:  # Not allowing the player to go wrong way
        if player_finish_poi_collide[1] == 0:
            player_car2.bounce()  # Bouncing back from the Wrong way
        else:
            game_info.next_round()
            print("player2 win round")
            player_car1.reset()  # Reset Player 1 Position
            player_car2.reset()  # Reset Player 2 Position
            player_car3.reset()  # Reset Player 3 Position
            player_car4.reset()  # Reset Player 4 Position

    player_finish_poi_collide = player_car3.collide(
        FINISH_MASK, *FINISH_POSITION)
    if player_finish_poi_collide != None:  # Not allowing the player to go wrong way
        if player_finish_poi_collide[1] == 0:
            player_car3.bounce()  # Bouncing back from the Wrong way
        else:
            game_info.next_round()
            print("player3 win round")
            player_car1.reset()  # Reset Player 1 Position
            player_car2.reset()  # Reset Player 2 Position
            player_car3.reset()  # Reset Player 3 Position
            player_car4.reset()  # Reset Player 4 Position

    player_finish_poi_collide = player_car4.collide(
        FINISH_MASK, *FINISH_POSITION)
    if player_finish_poi_collide != None:  # Not allowing the player to go wrong way
        if player_finish_poi_collide[1] == 0:
            player_car4.bounce()  # Bouncing back from the Wrong way
        else:
            game_info.next_round()
            print("player4 win round")
            player_car1.reset()  # Reset Player 1 Position
            player_car2.reset()  # Reset Player 2 Position
            player_car3.reset()  # Reset Player 3 Position
            player_car4.reset()  # Reset Player 4 Position


run = True
clock = pygame.time.Clock()
images = [(GRASS, (0, 0)), (TRACK, (0, 0)),
          (FINISH, FINISH_POSITION), (TRACK_BORDER, (0, 0))]  # Position of the Grass, Tracks and Track Border
player_car1 = PlayerCar1(8, 9)  # Player 1 Config
player_car2 = PlayerCar2(8, 9)  # Player 2 Config
player_car3 = PlayerCar3(8, 9)  # Player 3 Config
player_car4 = PlayerCar4(8, 9)  # Player 4 Config
game_info = GameInfo()

while run:
    clock.tick(FPS)
    draw(WIN, images, player_car1, player_car2, player_car3, player_car4, game_info)

    while not game_info.started:
        blit_text_center(
            WIN, MAIN_FONT, f"Press any key to start round {game_info.round}!")
        pygame.display.update()
        for event in pygame.event.get():

            if event.type == pygame.QUIT:
                pygame.quit()
                break

            if event.type == pygame.KEYDOWN:
                game_info.start_round()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False
            break

    move_player(player_car1)  # Allowing the car to move
    move_player2(player_car2)  # Allowing the car to move
    move_player3(player_car3)  # Allowing the car to move
    move_player4(player_car4)  # Allowing the car to move

    handle_collision(player_car1, player_car2, player_car3, player_car4, game_info)  # Allowing collision for winning

    if game_info.game_finished():  # Condition after wining the game
        blit_text_center(WIN, MAIN_FONT, "You won the game!")  # Show that you won
        pygame.time.wait(5000)  # Waiting for 5000 ticks (5000/fps = seconds)
        game_info.reset()  # Reset car position
        player_car1.reset()  # Reset car position
        player_car2.reset()  # Reset car position
        player_car3.reset()  # Reset car position
        player_car4.reset()  # Reset car position

pygame.quit()
