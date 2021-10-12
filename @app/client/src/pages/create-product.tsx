import {
  Button,
  ErrorText,
  LabeledInput,
  Layout,
  SharedLayout,
} from "@app/components";
import {
  CreateItemPropsQuery,
  useCreateCompanyMutation,
  useCreateItemMutation,
  useCreateItemPropsQuery,
} from "@app/graphql";
import { ErrorMessage } from "@hookform/error-message";
import { NextPage } from "next";
import * as React from "react";
import { useForm } from "react-hook-form";

const CreateProductPage: NextPage = () => {
  const createItemProps = useCreateItemPropsQuery();
  const data = createItemProps.data;

  return (
    <SharedLayout title="Activity" query={createItemProps}>
      {data && <CreateProductInner data={data} />}
    </SharedLayout>
  );
};

interface CreateProductInnerProps {
  data: CreateItemPropsQuery;
}

interface ProductFormInput {
  flavor: string;
}

const CreateProductInner: React.FC<CreateProductInnerProps> = ({
  data: { categories, companies },
}) => {
  const [createProduct] = useCreateItemMutation();
  console.log("createProduct: ", createProduct);
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
        <LabeledInput
          label="Flavor"
          id="flavor"
          placeholder="flavor"
          {...register("flavor")}
        />
        <Button type="submit">Create</Button>
      </form>
      <h1>Companies</h1>
      <CompanyForm companies={companies} />
    </Layout.Root>
  );
};

type CompanyFormInput = {
  name: string;
};

type CompanyFormProps = {
  companies: CreateItemPropsQuery["companies"];
};

const CompanyForm = ({ companies }: CompanyFormProps) => {
  const [createCompany] = useCreateCompanyMutation({
    refetchQueries: ["CreateProductProps"],
  });
  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<CompanyFormInput>();

  const onSubmit = ({ name }: CompanyFormInput) => {
    if (companies.nodes.some((c) => name === c.name)) {
      setError("name", { message: "Company by that name exist already" });
    } else {
      createCompany({ variables: { name } })
        .then((response) => console.log(response))
        .catch((error) => setError("name", { message: error.message }));
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <LabeledInput
        label="Company name"
        id="name"
        placeholder="name"
        {...register("name")}
      />
      <ErrorMessage
        errors={errors}
        name="name"
        render={({ message }) => <ErrorText>{message}</ErrorText>}
      />
      <Button type="submit">Add new company</Button>
    </form>
  );
};
export default CreateProductPage;
