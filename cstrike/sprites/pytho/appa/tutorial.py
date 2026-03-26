import pygame
import datetime
import time

BACKGROUND_COLOR = (240, 240, 240)
HEADER_COLOR = (0, 120, 255)
HEADER_FONT_COLOR = (255, 255, 255)
FOOTER_COLOR = (0, 120, 255)
FOOTER_FONT_COLOR = (255, 255, 255)
BUTTON_COLOR = (0, 120, 255)
BUTTON_HOVER_COLOR = (0, 150, 255)
FONT_COLOR = (255, 255, 255)
BUTTON_FONT_SIZE = 32
HEADER_FONT_SIZE = 48
TEXTBOX_COLOR = (0, 0, 0)
TEXTBOX_BORDER_COLOR = (100, 100, 100)
TEXTBOX_FONT_COLOR = (0, 0, 0)
TEXTBOX_FONT_SIZE = 42
TEXT_PROMPT_COLOR = (100, 100, 100)
TEXT_PROMPT_FONT_SIZE = 34
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
MAX_LOGIN_ATTEMPTS = 5
login_attempts = 0


class Button:
    def __init__(self, x, y, width, height, text, font, action):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.font = font
        self.action = action
        self.hovered = False

    def draw(self, surface):
        color = BUTTON_HOVER_COLOR if self.hovered else BUTTON_COLOR
        pygame.draw.rect(surface, color, self.rect, border_radius=8)
        text_surface = self.font.render(self.text, True, FONT_COLOR)
        text_rect = text_surface.get_rect(center=self.rect.center)
        surface.blit(text_surface, text_rect)

    def handle_event(self, event):
        if event.type == pygame.MOUSEMOTION:
            self.hovered = self.rect.collidepoint(event.pos)
        elif event.type == pygame.MOUSEBUTTONDOWN:
            if self.rect.collidepoint(event.pos):
                self.action()


class TextBox:
    def __init__(self, x, y, width, height, font, prompt_text="Enter your name:"):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = ""
        self.font = font
        self.active = False
        self.prompt_text = prompt_text
        self.border_radius = 8
        self.comment = ""

    def draw(self, surface):
        pygame.draw.rect(surface, TEXTBOX_COLOR, self.rect, 2, border_radius=self.border_radius)
        if not self.text:
            prompt_surface = self.font.render(self.prompt_text, True, TEXT_PROMPT_COLOR)
            surface.blit(prompt_surface, (self.rect.x + 5, self.rect.y + 5))
        else:
            text_surface = self.font.render(self.text, True, TEXTBOX_FONT_COLOR)
            surface.blit(text_surface, (self.rect.x + 5, self.rect.y + 5))

        if self.comment:
            comment_surface = self.font.render(str(self.comment), True, (255, 0, 0))
            surface.blit(comment_surface, (self.rect.x - 65, self.rect.y + self.rect.height + 5))

    def handle_event(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN:
            if self.rect.collidepoint(event.pos):
                self.active = True
            else:
                self.active = False
        if event.type == pygame.KEYDOWN and self.active:
            if event.key == pygame.K_BACKSPACE:
                self.text = self.text[:-1]
            elif event.key == pygame.K_RETURN:
                self.active = False
            else:
                self.text += event.unicode


def quit_game():
    pygame.quit()
    quit()


def check_credentials(username, password):
    with open('login.txt', 'r') as file:
        for line in file:
            line = line.strip()
            if line:
                stored_username, stored_password = line.split(':')
                if username == stored_username and password == stored_password:
                    return True
    return False


def login(textbox_username, textbox_password):
    global login_attempts
    username = textbox_username.text
    password = textbox_password.text
    timestamp = datetime.datetime.now()

    if login_attempts < MAX_LOGIN_ATTEMPTS:
        if check_credentials(username, password):
            textbox_password.comment = "Password correct!"
            print("Login successful!")
            log_message = f"SUCCESSFUL LOGIN: Username: {username}, Timestamp: {timestamp}"
        else:
            textbox_password.comment = "Incorrect username or password"
            print("Incorrect username or password")
            log_message = f"FAILED LOGIN: Username: {username}, Timestamp: {timestamp}"
            login_attempts += 1

        with open("log.txt", "a") as log_file:
            log_file.write(log_message + "\n")

        if login_attempts == MAX_LOGIN_ATTEMPTS:
            textbox_password.comment = "Maximum login attempts reached"
            time.sleep(3)
            print("Maximum login attempts reached. Exiting...")
            pygame.quit()
            quit()
    else:
        print("Maximum login attempts reached. Exiting...")
        textbox_password.comment = "Maximum login attempts reached"
        time.sleep(3)
        pygame.quit()
        quit()


def main():
    pygame.init()

    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption("Please Login To Your Account")

    font = pygame.font.Font(None, BUTTON_FONT_SIZE)
    header_font = pygame.font.Font(None, HEADER_FONT_SIZE)
    textbox_font = pygame.font.Font(None, TEXTBOX_FONT_SIZE)

    header_text = header_font.render("Login Panel", True, HEADER_FONT_COLOR)
    header_text_rect = header_text.get_rect(center=(SCREEN_WIDTH // 2, 30))

    button_login = Button(550, 500, 200, 50, "Login", font, lambda: login(textbox_username, textbox_password))
    button_exit = Button(50, 500, 200, 50, "EXIT", font, quit_game)

    textbox_username = TextBox(250, 220, 300, 40, textbox_font, "Username:")
    textbox_password = TextBox(250, 240, 300, 40, textbox_font, "Password:")
    textbox_password.rect.y += 60

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            textbox_username.handle_event(event)
            textbox_password.handle_event(event)
            button_login.handle_event(event)
            button_exit.handle_event(event)

        screen.fill(BACKGROUND_COLOR)

        pygame.draw.rect(screen, HEADER_COLOR, (0, 0, SCREEN_WIDTH, 60))
        screen.blit(header_text, header_text_rect)

        button_login.draw(screen)
        button_exit.draw(screen)

        textbox_username.draw(screen)
        textbox_password.draw(screen)

        pygame.display.update()

    pygame.quit()


if __name__ == "__main__":
    main()
