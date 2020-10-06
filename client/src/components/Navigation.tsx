import {
  faIceCream,
  faStream,
  faUserCircle,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { AnimateSharedLayout, motion } from "framer-motion";
import React from "react";
import { Link, useLocation } from "react-router-dom";
import styled from "styled-components";
import { theme } from "../common";

type IconDefinition = typeof faIceCream;

export const Navigation = () => {
  const location = useLocation();
  const currentLocation = location.pathname.split("/")[1];

  return (
    <Container>
      <AnimateSharedLayout>
        <NavTab currentLocation={currentLocation} path="/" icon={faStream} />
        <NavTab
          currentLocation={currentLocation}
          path="/treats"
          icon={faIceCream}
        />
        <NavTab
          currentLocation={currentLocation}
          path="/account"
          icon={faUserCircle}
        />
      </AnimateSharedLayout>
    </Container>
  );
};

const NavTab: React.FC<{
  currentLocation: string;
  path: string;
  icon: IconDefinition;
}> = ({ currentLocation, path, icon }) => {
  const isActive = currentLocation === path.slice(1);

  return (
    <NavLink to={path}>
      <FontAwesomeIcon
        size="2x"
        color={!isActive ? theme.colors.darkGray : theme.colors.white}
        icon={icon}
        style={{ zIndex: 100 }}
      />

      {isActive && <Active />}
    </NavLink>
  );
};

const Container = styled.div`
  display: flex;
  padding: 5px;
  width: 100%;
  height: 70px;
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
