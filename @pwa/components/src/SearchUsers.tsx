
import { Nullable } from "@pwa/common/src";
import React from "react";
import { SubmitHandler, useForm } from "react-hook-form";
import { Button } from "./Button";
import { Input } from "./Input";
import { styled } from "./stitches.config";


type SearchFormInput = {
  search: string;
}

export const SearchUsers = ({onSubmit, initialValue}: {onSubmit: SubmitHandler<SearchFormInput>, initialValue?: string}) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<SearchFormInput>({defaultValues: {search: initialValue}});

  return (
      <Form onSubmit={handleSubmit(onSubmit)}>
        <Input
          id="search"
          autoComplete="search"
          placeholder="Search users..."
          aria-invalid={errors.search ? "true" : "false"}
          css={{width: "100%"}}
          {...register("search", {
            required: true,
            min: 2,
          })}
        />
        <Button type="submit" css={{width: "10rem"}}>Search</Button>
      </Form>
  )
}

const Form = styled("form", {
  display: "flex",
  alignItems: "center",
  gap: "12px",

  borderRadius: "8px",
  padding: 24,
  width: "min(95vw, 36rem)",

  backgroundColor: "rgba(45, 46, 48, 1.00)",
  boxShadow:
    "hsl(206 22% 7% / 35%) 0px 10px 38px -10px, hsl(206 22% 7% / 20%) 0px 10px 20px -15px",
  "@media (prefers-reduced-motion: no-preference)": {
    animationDuration: "400ms",
    animationTimingFunction: "cubic-bezier(0.16, 1, 0.3, 1)",
  },
});
