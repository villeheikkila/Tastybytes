import { prisma } from '../../generated/prisma-client';

export const createIfNewCompany = async name => {
    const companyExists = await prisma.$exists.company({
        name,
    });

    const companyObject = companyExists
        ? await prisma.companies({
              where: { name },
          })
        : await prisma.createCompany({
              name,
          });

    const company = companyObject[0] || companyObject;

    return company.id;
};

export const createIfNewSubCategories = async (subCategories, categoryId) => {
    const subCategoriesIds: any = [];

    for (let i = 0; i < subCategories.length; i++) {
        const subCategoryExists = await prisma.$exists.subCategory({
            name: subCategories[i],
        });

        if (!subCategoryExists) {
            const res = await prisma.createSubCategory({
                category: { connect: { id: categoryId } },
                name: subCategories[i],
            });

            subCategoriesIds.push({ id: res.id });
        } else {
            const res = await prisma.subCategories({
                where: { name: subCategories[i] },
            });

            subCategoriesIds.push({ id: res[0].id });
        }
    }

    return subCategoriesIds;
};
