import { useUser } from "@supabase/auth-helpers-react";
import {
  createContext,
  MutableRefObject,
  PropsWithChildren,
  useContext,
  useEffect,
  useRef,
  useState,
} from "react";
import { API } from "../api";
import { Profile } from "../api/profile";
import { Database } from "../generated/DatabaseDefinitions";

export function useInView(
  ref: MutableRefObject<HTMLDivElement | null>,
  rootMargin: string = "0px"
): boolean {
  const [isIntersecting, setIntersecting] = useState<boolean>(false);

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
      API.profiles.getProfileById(userId).then((profile) => {
        setProfile(profile);
        modifyColorScheme(profile.color_scheme);
      });
    }
  }, [userId]); // TODO: Update when profile object is updated

  return (
    <ProfileContext.Provider value={profile}>
      {children}
    </ProfileContext.Provider>
  );
};

export const useInfinityScroll = <T,>(
  fetcher: (page: number) => Promise<T[]>,
  initialValues = [] as T[] // Hardcoded to be the size of one page
) => {
  const [items, setItems] = useState<T[]>(initialValues);
  const [page, setPage] = useState(initialValues ? 1 : 0);
  const ref = useRef<HTMLDivElement | null>(null);
  const inView = useInView(ref);

  useEffect(() => {
    fetcher(page).then((i) => {
      setItems(items.concat(i));
      setPage((p) => p + 1);
    });
  }, [inView]);

  return [items, ref] as const;
};

export const modifyColorScheme = (
  colorScheme: Database["public"]["Enums"]["color_scheme"]
) => {
  switch (colorScheme) {
    case "dark": {
      document.documentElement.classList.toggle("dark");
    }
    case "light": {
      document.documentElement.classList.remove("dark");
    }
    case "system": {
      if (
        globalThis?.window.matchMedia("(prefers-color-scheme: dark)").matches
      ) {
        document.documentElement.classList.toggle("dark");
      }
    }
  }
};
