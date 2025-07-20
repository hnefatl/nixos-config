{ config, pkgs, lib, firefox-addons, ... }:

{
  nixpkgs.overlays = [
    firefox-addons.overlays.default
  ];

  programs.firefox = {
    enable = true;

    profiles.keith = {
      search = {
        force = true;
        # TODO: enable
        #default = "kagi";
        #privateDefault = "ddg";
        #order = ["kagi" "ddg" "google"];
        #engines = {
        #  kagi = {
        #    name = "Kagi";
        #    urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
        #    icon = "https://kagi.com/favicon.ico";
        #  };
        #  bing.metaData.hidden = true;
        #};
      };
      extensions = {
        force = true;
        packages = with pkgs.firefox-addons; [
          ublock-origin
          dashlane
          consent-o-matic
          vimium
        ];
      };
      bookmarks = {};
      # about:config
      settings = {
        # Allow auto-enabling extensions.
        "extensions.autoDisableScopes" = 0;

        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.ml.chat.sidebar" = false;

        "browser.urlbar.sponsoredTopSites" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.quicksuggest.impressionCaps.sponsoredEnabled" = false;
        "browser.urlbar.quicksuggest.impressionCaps.nonSponsoredEnabled" = false;

        "ui.key.menuAccessKeyFocuses" = false;

        "browser.disableResetPrompt" = true;
        "browser.feeds.showFirstRunUI" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.uitour.enabled" = false;
        "startup.homepage_welcome_url" = "";
        "startup.homepage_override_url" = "";

        "browser.download.useDownloadDir" = true;  # Often want /tmp

        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.section.snippets" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;

        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;  # Password manager
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
      };
    };
    profiles."tmp".id = 1;
  };
}
