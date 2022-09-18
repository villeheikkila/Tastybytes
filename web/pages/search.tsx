import { List, ListInput, ListItem } from "konsta/react";
import Link from "next/link";
import { useRouter } from "next/router";
import { useEffect, useState } from "react";
import { API } from "../client";
import { ProductJoined } from "../client/products";
import Layout from "../components/layout";
import { constructProductName } from "../utils";
import { useDebounce } from "../utils/hooks";
import { paths } from "../utils/paths";

export default function Search() {
  const router = useRouter();
  const [searchTerm, setSearchTerm] = useState("");
  const debouncedSearchTerm = useDebounce<string>(searchTerm, 200);
  const [products, setProducts] = useState<ProductJoined[]>([]);

  useEffect(() => {
    API.products.search(debouncedSearchTerm).then((p) => setProducts(p));
  }, [debouncedSearchTerm]);

  return (
    <Layout title="Search">
      <List>
        <ListInput
          type="text"
          placeholder="Search..."
          onChange={(v: any) => setSearchTerm(v.target.value)}
        />

        {products.map((product) => (
          <ListItem
            key={product.id}
            link
            header={product["sub-brands"].brands.companies.name}
            title={constructProductName(product)}
            footer={product.description}
            onClick={() => router.push(paths.products.root(product.id))}
          />
        ))}
      </List>
    </Layout>
  );
}
