import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { Block, Card, Link, Page } from "konsta/react";
import { GetServerSideProps } from "next";
import { MutableRefObject, useEffect, useRef, useState } from "react";

const fetchCheckIns = async (username: string, page: number) => {
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

const UserProfile = ({ initialCheckIns, summary, username }: any) => {
  const [checkIns, setCheckIns] = useState<any>(initialCheckIns);
  const [page, setPage] = useState(1);
  const ref: any = useRef<HTMLDivElement>();
  const inView = useInView(ref, "100px");

  useEffect(() => {
    fetchCheckIns(username, page).then((d) => {
      setCheckIns(checkIns.concat(d));
      setPage((p) => p + 1);
    });
  }, [inView, username]);
  console.log("inView: ", inView);
  console.log("summary: ", summary);
  return (
    <Page>
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
          backgroundColor: inView ? "#23cebd" : "#efefef",
        }}
      >
        {checkIns?.map((c: any) => (
          <Card
            key={c?.id}
            header={
              <div className="-mx-4 -my-2 h-48 p-4 flex items-end  font-bold bg-cover bg-center">
                {c?.products?.["sub-brands"]?.brands?.companies?.name}{" "}
                {c?.products?.["sub-brands"]?.brands?.name}{" "}
                {c?.products?.["sub-brands"]?.name ?? ""} {c?.products?.name}
              </div>
            }
            footer={
              <div className="flex justify-between">
                <Link>Like</Link>
              </div>
            }
          >
            <div className="text-gray-500 mb-3">{c?.created_at}</div>
            <p>{c.review}</p>
            <p>{c.rating}</p>
          </Card>
        ))}
        <div ref={ref} />
      </Block>
    </Page>
  );
};

function useInView<T extends Element>(
  ref: MutableRefObject<T>,
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
      observer.unobserve(ref.current);
    };
  }, []);
  return isIntersecting;
}

export const getServerSideProps: GetServerSideProps = async (context) => {
  const username = context.params?.username;
  console.log("username: ", username);

  const { data: profile } = await supabaseClient
    .from("profiles")
    .select("id")
    .eq("username", username)
    .single();

  const initialCheckIns = await fetchCheckIns(username, 0);
  const { data: summary, error: summaryError } = await supabaseClient
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
