# Personal user and localization configuration
# Edit these values to personalize this dotfiles / NixOS setup for your own machine.
{
  username = "noahpro";
  name = "Noah Provenzano";
  email = "noahpro@gmail.com";
  defaultHostname = "noah-laptop";

  # Default timezone when location is unavailable or static
  timeZone = "America/New_York";

  # Default system locale
  locale = "en_US.UTF-8";

  # Enable automatic timezone updates based on Wi-Fi / geolocation when traveling
  autoTimeZone = true;
}

