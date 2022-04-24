import { Form, Link } from "@remix-run/react";
import type { User } from "@supabase/supabase-js";
import { styled } from "~/stitches.config";
import { paths } from "~/utils";
import { Avatar } from "./avatar";
import { Dropdown } from "./dropdown";

const Header = styled("header", {
  position: "fixed",
  zIndex: 10,
  top: 0,
  left: 0,

  height: "70px",
  width: "100%",
  backdropFilter: "blur(20px)",
  backgroundColor: "rgba(000, 000, 000, 0.5)",
  display: "flex",
  justifyContent: "center",
  alignContent: "center",

  boxShadow: "0 8px 12px rgba(0, 0, 0, 0.25)",
  border: "1px solid rgba(0, 0, 0, 0, 0.3)",
});

interface NavigationProps {
  user: User | null;
}

export const Navigation = ({ user }: NavigationProps) => {
  return (
    <Header>
      <Content>
        <Link to="/">
          <ProjectLogo>
            <img
              color="white"
              alt="project logo"
              src="/favicon.svg"
              height={32}
              width={32}
            />
            <LogoText>Tasted</LogoText>
          </ProjectLogo>
        </Link>
        <Flex>
          <Search />
          {user ? <DropdownMenu user={user} /> : <Link to="/login">Login</Link>}
        </Flex>
      </Content>
    </Header>
  );
};

export const Search = () => {
  return (
    <SearchForm method="get" action="/search">
      <SearchInput
        id="search"
        name="term"
        type="text"
        placeholder="Search..."
      />
      <SearchButton type="submit">
        <img src="/assets/search.svg" alt="search icon" />
      </SearchButton>
    </SearchForm>
  );
};

const SearchForm = styled(Form, {
  display: "flex",
  alignItems: "center",
  gap: "0.5rem",
  backdropFilter: "blur(20px)",
  borderRadius: "10px",
  color: "#bababa",
  backgroundColor: "rgba(45, 46, 48, 0.5)",
  padding: "0px 16px",
  fontSize: "16px",
  height: "40px",
  border: "none",
  "&:focus": { outline: "1px solid $blue" },
  transition: "outline 0.4s ease 0s, color 0.2s ease 0s",
  "&[aria-invalid='true']": {
    outline: "1px solid red",
  },
});

const SearchInput = styled("input", {
  display: "inline-block",
  height: "100%",
  width: "100%",
});

const SearchButton = styled("button", {});

interface DropdownMenuProps {
  user: User | null;
}

const DropdownMenu: React.FC<DropdownMenuProps> = ({ user }) => {
  return (
    <Dropdown.Menu>
      <Dropdown.Trigger asChild>
        <IconButton>
          <Avatar name={user?.email ?? ""} status={undefined} />
        </IconButton>
      </Dropdown.Trigger>

      <Dropdown.Content sideOffset={-53}>
        <Dropdown.Item>
          <Link to={paths.user(user?.id ?? "")}>Profile</Link>
        </Dropdown.Item>
        <Dropdown.Separator />
        <Dropdown.Item>
          <Link to={paths.settings}>Settings</Link>
        </Dropdown.Item>
        <Dropdown.Separator />
        <Dropdown.Item>
          <Link to={paths.logout}>Logout</Link>
        </Dropdown.Item>
      </Dropdown.Content>
    </Dropdown.Menu>
  );
};

const IconButton = styled("button", {
  all: "unset",
  fontFamily: "inherit",
  borderRadius: "100%",
  height: "42px",
  width: "42px",
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  color: "$white",
  backgroundColor: "white",
  boxShadow: `0 2px 10px $black`,
  "&:hover": { backgroundColor: "$turq" },
  "&:focus": { boxShadow: `0 0 0 2px black` },
});

const Flex = styled("div", {
  display: "flex",
  justifyContent: "center",
  alignItems: "center",
  gap: "8px",
});

export const Content = styled("div", {
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
  width: "900px",
  padding: "12px",
});

const ProjectLogo = styled("div", {
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  gap: "8px",

  ":hover": {
    color: "$blue",
  },
});

const LogoText = styled("h1", {
  fontSize: "32px",
  color: "white",
  fontWeight: 700,
  alignText: "center",
  display: "none",

  "@media (min-width: 480px)": {
    display: "block",
  },
});
