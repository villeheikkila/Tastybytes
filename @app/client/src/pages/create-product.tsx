import { Button, LabeledInput, Layout, SharedLayout } from "@app/components";
import {
  CreateProductPropsQuery,
  useCreateProductMutation,
  useCreateProductPropsQuery,
} from "@app/graphql";
import { NextPage } from "next";
import * as React from "react";
import { useForm } from "react-hook-form";

const CreateProductPage: NextPage = () => {
  const createItemProps = useCreateProductPropsQuery();
  const data = createItemProps.data;

  return (
    <SharedLayout title="Activity" query={createItemProps}>
      {data && <CreateProductInner data={data} />}
    </SharedLayout>
  );
};

interface CreateProductInnerProps {
  data: CreateProductPropsQuery;
}

interface ProductFormInput {
  flavor: string;
}

const CreateProductInner: React.FC<CreateProductInnerProps> = ({
  data: { categories, companies },
}) => {
  const [createProduct] = useCreateProductMutation();
  const [category, setCategory] = React.useState<string>();
  const [brand, setBrand] = React.useState<string>();
  const [type, setType] = React.useState<string>();
  console.log("type: ", type);
  const [company, setCompany] = React.useState<string>();
  console.log("company: ", company);
  const { register, handleSubmit } = useForm<ProductFormInput>();

  const onSubmit = async ({ flavor }: ProductFormInput) => {
    console.log("flavor: ", flavor);
    if (!type || !company || !brand) return;
    const typeId = parseInt(type, 10);
    console.log("typeId: ", typeId);
    const companyId = parseInt(company, 10);

    const brandId = parseInt(brand, 10);
    console.log("brandId: ", brandId);
    try {
      const res = await createProduct({
        variables: {
          flavor,
          typeId,
          brandId,
          manufacturerId: companyId,
          description: "asdsad",
        },
      });
      console.log("res: ", res);
    } catch (e) {
      console.error(e);
    }
  };

  const types = React.useMemo(
    () => categories.nodes.find((e) => e.name === category)?.typesByCategory,
    [category, categories.nodes]
  );

  const brands = React.useMemo(
    () => companies.nodes.find((e) => e.id.toString() === company)?.brands,
    [company, companies.nodes]
  );

  return (
    <Layout.Root>
      <Layout.Header>Create New Product</Layout.Header>
      <div />
      asdasd
      <select onChange={(v) => setCategory(v.target.value)}>
        {categories.nodes.map((category) => (
          <option key={category.name} value={category.name}>
            {category.name}
          </option>
        ))}
      </select>
      <select onChange={(v) => setType(v.target.value)}>
        {types?.nodes.map((type) => (
          <option key={type.id} value={type.id}>
            {type.name}
          </option>
        ))}
      </select>
      <select onChange={(v) => setCompany(v.target.value)}>
        {companies?.nodes.map((company) => (
          <option key={company.id} value={company.id}>
            {company.name}
          </option>
        ))}
      </select>
      <select onChange={(v) => setBrand(v.target.value)}>
        {brands?.nodes.map((brand) => (
          <option key={brand.id} value={brand.id}>
            {brand.name}
          </option>
        ))}
      </select>
      <form onSubmit={handleSubmit(onSubmit)}>
        <input id="flavor" {...register("flavor")} placeholder="flavor" />
        <button type="submit">Create</button>
      </form>
    </Layout.Root>
  );
};

export default CreateProductPage;
