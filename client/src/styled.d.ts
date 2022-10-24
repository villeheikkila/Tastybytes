import { theme } from "./common";

type ThemeInterface = typeof theme;

declare module "styled-components" {
  interface DefaultTheme extends ThemeInterface {}
}
