# Import required modules
import pygame
import random
import string
import time
import sys
import math

# Initialize Pygame
pygame.init()
pygame.mixer.init()  # Initialize Pygame mixer for sound

# Constants
SCREEN_WIDTH = 600
SCREEN_HEIGHT = 600
CIRCLE_RADIUS = 20
BACKGROUND_COLOR = (68, 68, 68)
CLICK_CIRCLE_COLOR = (0, 153, 204)
ALPHABET_CIRCLE_COLOR = (200, 200, 200)
RED_CIRCLE_COLOR = (200, 200, 200)
FONT_COLOR = (200, 200, 200)
ALPHABET_FONT_COLOR = (68, 68, 68)
TIME_FONT_SIZE = 256
SCORE_FONT_SIZE = 36
ALPHABET_FONT_SIZE = 32
GAME_DURATION = 30

# Create Pygame window
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Clicking and Typing Game")

# Load sound files
click_sound = pygame.mixer.Sound("sound.mp3")
keyboard_sound = pygame.mixer.Sound("keyboard.mp3")

# Font settings
time_font = pygame.font.Font(None, TIME_FONT_SIZE)
time_font.set_bold(True)
score_font = pygame.font.Font(None, SCORE_FONT_SIZE)
score_font.set_bold(True)
alphabet_font = pygame.font.Font(None, ALPHABET_FONT_SIZE)

# Game state variables
game_state = "start"
score = 0
start_time = 0
last_interaction_time = time.time()

# Smooth movement settings
move_duration = 1.0  # Duration of circle movement in seconds

# Smooth movement variables
click_circle_target = (0, 0)
alphabet_circle_target = (0, 0)
red_circle_target = (0, 0)

click_circle_start_time = None
alphabet_circle_start_time = None
red_circle_start_time = None

click_circle_pos = (0, 0)
alphabet_circle_pos = (0, 0)
red_circle_pos = (0, 0)


def random_positions():
    """Generate random target positions for circles."""
    global click_circle_target, alphabet_circle_target, red_circle_target

    click_circle_target = (
        random.randint(CIRCLE_RADIUS, SCREEN_WIDTH - CIRCLE_RADIUS),
        random.randint(CIRCLE_RADIUS, SCREEN_HEIGHT - CIRCLE_RADIUS),
    )

    alphabet_circle_target = (
        random.randint(CIRCLE_RADIUS, SCREEN_WIDTH - CIRCLE_RADIUS),
        random.randint(CIRCLE_RADIUS, SCREEN_HEIGHT - CIRCLE_RADIUS),
    )

    red_circle_target = (
        random.randint(CIRCLE_RADIUS, SCREEN_WIDTH - CIRCLE_RADIUS),
        random.randint(CIRCLE_RADIUS, SCREEN_HEIGHT - CIRCLE_RADIUS),
    )


def reset_game():
    """Reset the game to its initial state."""
    global game_state, current_alphabet, score, start_time, last_interaction_time
    global click_circle_start_time, alphabet_circle_start_time, red_circle_start_time
    global click_circle_pos, alphabet_circle_pos, red_circle_pos

    game_state = "start"
    current_alphabet = random.choice(string.ascii_uppercase)
    score = 0
    start_time = 0
    last_interaction_time = time.time()

    random_positions()

    # Reset starting positions and times
    click_circle_pos = click_circle_target
    alphabet_circle_pos = alphabet_circle_target
    red_circle_pos = red_circle_target

    click_circle_start_time = None
    alphabet_circle_start_time = None
    red_circle_start_time = None


reset_game()


def lerp(start, end, t):
    """Linear interpolation function to calculate a value at time t between start and end."""
    return start + t * (end - start)


def update_position(start_pos, target_pos, start_time, current_time):
    """Update the position of a circle smoothly using linear interpolation."""
    # Calculate the time elapsed since the animation started
    elapsed_time = current_time - start_time

    # Calculate the fraction of animation duration that has passed
    fraction = min(elapsed_time / move_duration, 1.0)

    # Calculate the interpolated position using linear interpolation
    new_x = lerp(start_pos[0], target_pos[0], fraction)
    new_y = lerp(start_pos[1], target_pos[1], fraction)

    return new_x, new_y


def draw_centered_text(text, font, color, surface, y):
    """Draw centered text on the screen."""
    text_obj = font.render(text, True, color)
    text_rect = text_obj.get_rect(center=(SCREEN_WIDTH / 2, y))
    surface.blit(text_obj, text_rect)


def draw_alphabet_circle():
    """Draw the alphabet circle on the screen."""
    pygame.draw.circle(screen, ALPHABET_CIRCLE_COLOR, alphabet_circle_pos, CIRCLE_RADIUS)
    text_obj = alphabet_font.render(current_alphabet, True, ALPHABET_FONT_COLOR)
    text_rect = text_obj.get_rect(center=alphabet_circle_pos)
    screen.blit(text_obj, text_rect)


def draw_clicking_circle():
    """Draw the clicking circle on the screen."""
    pygame.draw.circle(screen, CLICK_CIRCLE_COLOR, click_circle_pos, CIRCLE_RADIUS)


def draw_red_circle():
    """Draw the red circle on the screen."""
    pygame.draw.circle(screen, RED_CIRCLE_COLOR, red_circle_pos, CIRCLE_RADIUS)


# Game loop for "start" state
while game_state == "start":
    screen.fill(BACKGROUND_COLOR)
    draw_centered_text("Welcome to the Game!", score_font, FONT_COLOR, screen, SCREEN_HEIGHT / 2 - 25)
    draw_centered_text("Click anywhere to start", score_font, FONT_COLOR, screen, SCREEN_HEIGHT / 2 + 25)
    pygame.display.update()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        elif event.type == pygame.MOUSEBUTTONDOWN:
            game_state = "playing"
            start_time = time.time()
            last_interaction_time = start_time  # Update the last interaction time

# Game loop for "playing" state
while game_state == "playing":
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        elif event.type == pygame.MOUSEBUTTONDOWN:
            mouse_x, mouse_y = event.pos

            # Update last interaction time
            last_interaction_time = time.time()

            # Calculate distances to each circle
            click_distance = ((mouse_x - click_circle_pos[0]) ** 2 + (mouse_y - click_circle_pos[1]) ** 2) ** 0.5
            alphabet_distance = ((mouse_x - alphabet_circle_pos[0]) ** 2 + (
                    mouse_y - alphabet_circle_pos[1]) ** 2) ** 0.5
            red_distance = ((mouse_x - red_circle_pos[0]) ** 2 + (mouse_y - red_circle_pos[1]) ** 2) ** 0.5

            # Check for clicking circle
            if click_distance <= CIRCLE_RADIUS:
                # Play the click sound
                click_sound.play()

                # Increment the score
                score += 1

                # Generate new random positions for the circles
                random_positions()

                # Start the movement
                click_circle_start_time = time.time()

            # Check for red circle
            elif red_distance <= CIRCLE_RADIUS:
                game_state = "game_over"

            # Check for alphabet circle
            elif alphabet_distance <= CIRCLE_RADIUS:
                # Decrement the score if clicked on the alphabet circle
                score -= 1

        elif event.type == pygame.KEYDOWN:
            # Update last interaction time
            last_interaction_time = time.time()

            # Check if the key pressed matches the current alphabet
            if event.unicode.upper() == current_alphabet:
                # Play the keyboard sound
                keyboard_sound.play()

                # Increment the score
                score += 1

                # Generate new random positions for the circles
                random_positions()

                # Start the movement
                alphabet_circle_start_time = time.time()

                # Select a new alphabet for the next round
                current_alphabet = random.choice(string.ascii_uppercase)
            else:
                # Decrement the score for incorrect key press
                score -= 1

    # Get the current time
    current_time = time.time()

    # Update the positions of the circles
    if click_circle_start_time is not None:
        click_circle_pos = update_position(click_circle_pos, click_circle_target, click_circle_start_time, current_time)
        # Check if the animation has completed
        if click_circle_start_time + move_duration <= current_time:
            click_circle_pos = click_circle_target
            click_circle_start_time = None

    if alphabet_circle_start_time is not None:
        alphabet_circle_pos = update_position(alphabet_circle_pos, alphabet_circle_target, alphabet_circle_start_time,
                                              current_time)
        # Check if the animation has completed
        if alphabet_circle_start_time + move_duration <= current_time:
            alphabet_circle_pos = alphabet_circle_target
            alphabet_circle_start_time = None

    # The same approach is used for the red circle as well
    if red_circle_start_time is not None:
        red_circle_pos = update_position(red_circle_pos, red_circle_target, red_circle_start_time, current_time)
        # Check if the animation has completed
        if red_circle_start_time + move_duration <= current_time:
            red_circle_pos = red_circle_target
            red_circle_start_time = None

    # Calculate remaining time and check if the game should transition to "game_over" state
    elapsed_time = current_time - start_time
    remaining_time = max(0, GAME_DURATION - elapsed_time)

    # Calculate time since last interaction
    time_since_last_interaction = current_time - last_interaction_time

    # If no interaction for 2 seconds, transition to "idle" state
    if time_since_last_interaction >= 2:
        game_state = "idle"
        continue

    # Clear the screen
    screen.fill(BACKGROUND_COLOR)

    # Draw the time remaining in the center of the screen
    draw_centered_text(f"{int(remaining_time)}", time_font, FONT_COLOR, screen, SCREEN_HEIGHT / 2)

    # Draw the circles
    draw_clicking_circle()
    draw_alphabet_circle()
    draw_red_circle()

    # Draw the score in the top-left corner
    score_text = score_font.render(f"{score}", True, FONT_COLOR)
    screen.blit(score_text, (10, 10))

    # Update the display
    pygame.display.update()

    if remaining_time <= 0:
        game_state = "game_over"


# Game loop for "idle" state
while game_state == "idle":
    screen.fill(BACKGROUND_COLOR)
    draw_centered_text("You did not press any key", score_font, FONT_COLOR, screen, SCREEN_HEIGHT / 2 - 25)
    draw_centered_text("Click anywhere to continue", score_font, FONT_COLOR, screen, SCREEN_HEIGHT / 2 + 25)
    pygame.display.update()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        elif event.type == pygame.MOUSEBUTTONDOWN or event.type == pygame.KEYDOWN:
            # Resume the game by resetting the game state and time
            reset_game()
            game_state = "playing"
            start_time = time.time()
            break

# Game loop for "game over" state
while game_state == "game_over":
    screen.fill(BACKGROUND_COLOR)
    draw_centered_text("Game Over!", score_font, FONT_COLOR, screen, SCREEN_HEIGHT / 2 - 25)
    draw_centered_text(f"Your final score is: {score}", score_font, FONT_COLOR, screen, SCREEN_HEIGHT / 2 + 25)
    draw_centered_text("Click to Exit", score_font, FONT_COLOR, screen, SCREEN_HEIGHT / 2 + 75)
    pygame.display.update()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        elif event.type == pygame.MOUSEBUTTONDOWN:
            reset_game()
            pygame.event.clear()
            game_state = "playing"
            start_time = time.time()
            break

# Quit Pygame and the script
pygame.quit()
sys.exit()
