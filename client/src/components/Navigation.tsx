import React from "react";
import styled from "styled-components";
import { Link, useLocation } from "react-router-dom";
import { ReactComponent as HomeIcon } from "../assets/home.svg";
import { ReactComponent as AccountIcon } from "../assets/account.svg";
import { ReactComponent as ActivityIcon } from "../assets/candy.svg";
import { motion, AnimateSharedLayout } from "framer-motion";

const Navigation = () => {
  const location = useLocation();
  const currentLocation = location.pathname.split("/")[1];

  return (
    <Container>
      <AnimateSharedLayout>
        <NavTab currentLocation={currentLocation} path="/" icon={HomeIcon} />
        <NavTab
          currentLocation={currentLocation}
          path="/treats"
          icon={ActivityIcon}
        />
        <NavTab
          currentLocation={currentLocation}
          path="/account"
          icon={AccountIcon}
        />
      </AnimateSharedLayout>
    </Container>
  );
};

const NavTab: React.FC<{
  currentLocation: string;
  path: string;
  icon: React.FunctionComponent<React.SVGProps<SVGSVGElement>>;
}> = ({ currentLocation, path, icon }) => {
  const isActive = currentLocation === path.slice(1);
  const Icon = icon;

  return (
    <NavLink to={path}>
      <Icon
        style={{ zIndex: 10 }}
        fill={
          isActive ? "rgba(255, 255, 255, 1.0)" : "rgba(255, 255, 255, 0.549)"
        }
      />
      {isActive && <Active />}
    </NavLink>
  );
};

const Container = styled.div`
  display: flex;
  padding: 5px;
  width: 100%;
  height: 60px;
  background-color: rgba(21, 21, 21);
  box-shadow: 0px 0px 8px rgba(0, 0, 0, 0.5);
`;

const Active = styled(motion.div).attrs({ layoutId: "tab-indicator" })`
  position: absolute;
  z-index: 1;
  top: 2px;
  bottom: 2px;
  left: 2px;
  right: 2px;
  background-color: rgba(0, 0, 0, 0.4);
  border-radius: 6px;
`;

const NavLink = styled(Link)`
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 1;
  height: 100%;
  transition: transform 100ms ease;
`;

export default Navigation;
