import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { Block, Card, Link } from "konsta/react";
import { GetServerSideProps } from "next";
import {
  MutableRefObject,
  RefObject,
  useEffect,
  useRef,
  useState,
} from "react";
import Layout from "../../components/layout";
import { Database } from "../../generated/DatabaseDefinitions";

type CheckIn = Database["public"]["Tables"]["check_ins"]["Row"] & {
  profiles: { id: number; username: string };
  products: {
    id: number;
    name: string;
    "sub-brands": {
      id: number;
      name: string;
      brands: {
        id: number;
        name: string;
        companies: { id: number; name: string | null };
      };
    };
    subcategories: {
      id: number;
      name: string;
      categories: { id: number; name: string };
    };
  };
};

const fetchCheckIns = async (
  username: string,
  page: number
): Promise<CheckIn[]> => {
  const firstCheckIn = page * 15;
  const lastCheckIn = (page + 1) * 15 - 1;

  const { data, error } = await supabaseClient
    .from("check_ins")
    .select(
      "id, rating, review, created_at, product_id, profiles (id, username), products (id, name, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name)))"
    )
    .range(firstCheckIn, lastCheckIn)
    .eq("profiles.username", username);

  if (error) {
    console.error(error);
  }

  return error ? [] : data;
};

interface UserProfile {
  initialCheckIns: CheckIn[];
  summary: {
    totalCheckIns: number;
    totalUnique: number;
    averageRating: number;
  };
  username: string;
}

const UserProfile = ({ initialCheckIns, summary, username }: UserProfile) => {
  const [checkIns, setCheckIns] = useState(initialCheckIns);
  const [page, setPage] = useState(1);
  const ref = useRef<HTMLDivElement | null>(null);
  const inView = useInView(ref);
  console.log("inView: ", inView);

  useEffect(() => {
    fetchCheckIns(username, page).then((d) => {
      setCheckIns(checkIns.concat(d));
      setPage((p) => p + 1);
    });
  }, [inView, username]);

  console.log("inView: ", inView);
  console.log("summary: ", summary);
  return (
    <Layout title={username} username={username}>
      <Block strong inset>
        <span>Total: {summary.totalCheckIns}</span>
      </Block>
      <Block strong inset>
        <span>Unique: {summary.totalUnique}</span>
      </Block>
      <Block strong inset>
        <span>Average: {summary.averageRating}</span>
      </Block>
      <Block
        style={{
          height: "100vh",
        }}
      >
        {checkIns.map((checkIn) => (
          <Card
            key={checkIn.id}
            header={
              <div className="-mx-4 -my-2 h-48 p-4 flex items-end  font-bold bg-cover bg-center">
                {checkIn.products?.["sub-brands"].brands.companies.name}{" "}
                {checkIn.products?.["sub-brands"].brands.name}{" "}
                {checkIn.products?.["sub-brands"].name ?? ""}{" "}
                {checkIn.products?.name}
              </div>
            }
            footer={
              <div className="flex justify-between">
                <Link>Like</Link>
              </div>
            }
          >
            <div className="text-gray-500 mb-3">{checkIn.created_at}</div>
            <p>{checkIn.review}</p>
            <p>{checkIn.rating}</p>
          </Card>
        ))}
        <div ref={ref}>Loading...</div>
      </Block>
    </Layout>
  );
};

function useInView<T extends Element>(
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

export const getServerSideProps: GetServerSideProps = async (context) => {
  const username = context.params?.username;

  if (!username) throw Error("user doesn't exist");

  const { data: profile } = await supabaseClient
    .from("profiles")
    .select("id")
    .eq("username", username)
    .single();

  const initialCheckIns = await fetchCheckIns(String(username), 0);

  const { data: summary } = await supabaseClient
    .rpc("get_profile_summary", { uid: profile?.id })
    .single();

  return {
    props: {
      initialCheckIns,
      username,
      summary: summary,
    },
  };
};

export default UserProfile;
