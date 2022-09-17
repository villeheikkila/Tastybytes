import { List, ListInput, ListItem } from "konsta/react";
import { useEffect, useState } from "react";
import { API } from "../api";
import { SearchProduct } from "../api/products";
import Layout from "../components/layout";
import { useDebounce, useInfinityScroll } from "../utils/hooks";

export default function Search() {
  const [searchTerm, setSearchTerm] = useState("");
  const debouncedSearchTerm = useDebounce<string>(searchTerm, 200);
  const [products, setProducts] = useState<SearchProduct[]>([]);

  useEffect(() => {
    API.products
      .searchProducts(debouncedSearchTerm)
      .then((p) => setProducts(p));
  }, [debouncedSearchTerm]);

  return (
    <Layout title="Search">
      <List>
        <ListInput
          type="text"
          placeholder="Search..."
          onChange={(v: any) => setSearchTerm(v.target.value)}
        />

        {products.map((p) => (
          <ListItem
            key={p.id}
            link
            header={p["sub-brands"].brands.companies.name}
            title={constructProductName(p)}
            footer={p.description}
            href={`/users/${p.name}`}
          />
        ))}
      </List>
    </Layout>
  );
}

const constructProductName = (p: SearchProduct) =>
  [p["sub-brands"].brands.name, p["sub-brands"].name, p.name]
    .flatMap((p) => (p === undefined || p === null || p === "" ? [] : p))
    .join(" ");
