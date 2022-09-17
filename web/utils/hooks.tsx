import { useUser } from "@supabase/auth-helpers-react";
import {
  createContext,
  MutableRefObject,
  PropsWithChildren,
  useContext,
  useEffect,
  useState,
} from "react";
import { API } from "../api";
import { Profile } from "../api/profile";

export function useInView(
  ref: MutableRefObject<HTMLDivElement | null>,
  rootMargin: string = "0px"
): boolean {
  const [isIntersecting, setIntersecting] = useState<boolean>(false);
  console.log("isIntersecting: ", isIntersecting);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        setIntersecting(entry.isIntersecting);
      },
      {
        rootMargin,
      }
    );
    if (ref.current) {
      observer.observe(ref.current);
    }
    return () => {
      ref.current && observer.unobserve(ref.current);
    };
  }, []);

  return isIntersecting;
}

export function useDebounce<T>(value: T, delay?: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay || 500);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}

const ProfileContext = createContext<Profile | null>(null);

export const useProfile = () => useContext(ProfileContext);

export const ProfileProvider = ({ children }: PropsWithChildren) => {
  const auth = useUser();
  const [profile, setProfile] = useState<Profile | null>(null);
  const userId = auth.user?.id;

  useEffect(() => {
    if (userId) {
      API.profiles
        .getProfileById(userId)
        .then((profile) => setProfile(profile));
    }
  }, [userId]); // TODO: Update when profile object is updated

  return (
    <ProfileContext.Provider value={profile}>
      {children}
    </ProfileContext.Provider>
  );
};
