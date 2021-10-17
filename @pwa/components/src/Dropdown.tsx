import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu";
import { styled, keyframes } from "./stitches.config";

const slideUpAndFade = keyframes({
  "0%": { opacity: 0, transform: "translateY(2px)" },
  "100%": { opacity: 1, transform: "translateY(0)" },
});

const slideRightAndFade = keyframes({
  "0%": { opacity: 0, transform: "translateX(-2px)" },
  "100%": { opacity: 1, transform: "translateX(0)" },
});

const slideDownAndFade = keyframes({
  "0%": { opacity: 0, transform: "translateY(-2px)" },
  "100%": { opacity: 1, transform: "translateY(0)" },
});

const slideLeftAndFade = keyframes({
  "0%": { opacity: 0, transform: "translateX(2px)" },
  "100%": { opacity: 1, transform: "translateX(0)" },
});

const StyledContent = styled(DropdownMenuPrimitive.Content, {
  minWidth: 240,
  backgroundColor: "$darkGray",
  borderRadius: "8px",
  boxShadow:
    "0 2px 10px rgb(0 0 0 / 20%)",
  "@media (prefers-reduced-motion: no-preference)": {
    animationDuration: "400ms",
    animationTimingFunction: "cubic-bezier(0.16, 1, 0.3, 1)",
    willChange: "transform, opacity",
    '&[data-state="open"]': {
      '&[data-side="top"]': { animationName: slideDownAndFade },
      '&[data-side="right"]': { animationName: slideLeftAndFade },
      '&[data-side="bottom"]': { animationName: slideUpAndFade },
      '&[data-side="left"]': { animationName: slideRightAndFade },
    },
  },
});

const itemStyles = {
  all: "unset",
  fontSize: "1rem",
  lineHeight: 1,
  color: "$white",
  borderRadius: 3,
  display: "flex",
  alignItems: "center",
  position: "relative",
  userSelect: "none",
  padding: "1rem 1.2rem",

  "&[data-disabled]": {
    color: "$white",
    pointerEvents: "none",
  },

  "&:focus": {
    opacity: 0.8,
  },

  "a": {
    color: "$white",
  },

  variants: {
    alignment: {
      "centered": {
        justifyContent: "center"
      }
    }
  }
};

const StyledItem = styled(DropdownMenuPrimitive.Item, { ...itemStyles });
const StyledCheckboxItem = styled(DropdownMenuPrimitive.CheckboxItem, {
  ...itemStyles,
});
const StyledRadioItem = styled(DropdownMenuPrimitive.RadioItem, {
  ...itemStyles,
});
const StyledTriggerItem = styled(DropdownMenuPrimitive.TriggerItem, {
  '&[data-state="open"]': {
    backgroundColor: "$darkGray",
    color: "$white",
  },
  ...itemStyles,
});

const StyledLabel = styled(DropdownMenuPrimitive.Label, {
  paddingLeft: 25,
  fontSize: 12,
  lineHeight: "25px",
  color: "$white",
});

const StyledSeparator = styled(DropdownMenuPrimitive.Separator, {
  height: 0.5,
  backgroundColor: "#5f6368",
});

const StyledItemIndicator = styled(DropdownMenuPrimitive.ItemIndicator, {
  position: "absolute",
  left: 0,
  width: 25,
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
});

const StyledArrow = styled(DropdownMenuPrimitive.Arrow, {
  fill: "white",
});

export const Dropdown = {
  Menu: DropdownMenuPrimitive.Root,
  Trigger: DropdownMenuPrimitive.Trigger,
  Content: StyledContent,
  Item: StyledItem,
  CheckboxItem: StyledCheckboxItem,
  RadioGroup: DropdownMenuPrimitive.RadioGroup,
  RadioItem: StyledRadioItem,
  ItemIndicator: StyledItemIndicator,
  TriggerItem: StyledTriggerItem,
  Label: StyledLabel,
  Separator: StyledSeparator,
  Arrow: StyledArrow,
};
