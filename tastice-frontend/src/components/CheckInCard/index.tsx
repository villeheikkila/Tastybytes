import React from "react";
import { Link as RouterLink } from "react-router-dom";
import Rating from "material-ui-rating";
import { blue } from "@material-ui/core/colors";
import MoreVertIcon from "@material-ui/icons/MoreVert";
import { ProductCard } from "../ProductCard";

import {
  Link,
  Typography,
  IconButton,
  Avatar,
  CardContent,
  CardHeader,
  Card,
  makeStyles
} from "@material-ui/core";

const useStyles = makeStyles(theme => ({
  card: {
    maxWidth: 700,
    margin: `${theme.spacing(1)}px auto`
  },
  media: {
    height: 0,
    paddingTop: "56.25%"
  },
  avatar: {
    backgroundColor: blue[500]
  },
  content: {}
}));

const months: any = {
  0: "January",
  1: "February",
  2: "March",
  3: "April",
  4: "May",
  5: "June",
  6: "July",
  7: "August",
  8: "September",
  9: "October",
  10: "November",
  11: "December"
};

export const CheckInCard: React.FC<any> = ({ checkin }) => {
  const classes = useStyles();

  const checkinObject = {
    authorFirstName: checkin.author.firstName,
    authorLastName: checkin.author.lastName,
    authorId: checkin.author.id,
    comment: checkin.comment,
    rating: checkin.rating,
    name: checkin.product.name,
    id: checkin.product.id,
    producer: checkin.product.producer,
    date: new Date(checkin.createdAt)
  };

  const productObject = {
    name: checkin.product.name,
    id: checkin.product.id,
    producer: checkin.product.producer,
    category: checkin.product.category,
    subCategory: checkin.product.subCategory
  };

  return (
    <div>
      <Card className={classes.card}>
        <CardHeader
          avatar={
            <Avatar aria-label="Author" src={""} className={classes.avatar}>
              R
            </Avatar>
          }
          action={
            <IconButton aria-label="Settings">
              <MoreVertIcon />
            </IconButton>
          }
          title={
            <Typography variant="h6" color="textSecondary" component="p">
              <Link
                component={RouterLink}
                to={`/user/${checkinObject.authorId}`}
              >
                {checkinObject.authorFirstName} {checkinObject.authorLastName}
              </Link>
            </Typography>
          }
          subheader={`${checkinObject.date.getDate()} ${
            months[checkinObject.date.getMonth()]
          }, ${checkinObject.date.getFullYear()}
          `}
        />
        <ProductCard product={productObject} />
        <CardContent className={classes.content}>
          <Typography variant="h6" color="textSecondary" component="p">
            Rating
          </Typography>
          <Rating value={checkinObject.rating} max={5} />
          <Typography variant="h6" color="textSecondary" component="p">
            {checkinObject.comment && <>Comment: {checkinObject.comment}</>}
          </Typography>
        </CardContent>
      </Card>
    </div>
  );
};
